import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_buddy/components/pdf_drop_zone.dart';
import 'package:pdf_buddy/services/pdf_service.dart';
import 'package:pdf_buddy/utils/theme.dart';
import 'package:pdf_buddy/providers/processing_providers.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:pdf_buddy/providers.dart';

// Add a provider to track PDF reordering operations to prevent excessive redraws
class MergePDFPage extends ConsumerWidget {
  const MergePDFPage({super.key});

  Widget _buildProgressIndicator(double progress) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16),
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            progress < 1.0 ? 'Merging PDFs...' : 'Finalizing...',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.primaryBlue.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryBlue,
                    ),
                    minHeight: 8,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfServiceProvider);
    final pdfData = ref.watch(pdfDataProvider);
    final additionalPdfs = ref.watch(additionalPdfsProvider);
    final progress = ref.watch(processingProgressProvider);

    final allPdfs = [
      if (pdfData != null)
        (pdfData, ref.read(pdfMetadataProvider)?.fileName ?? 'Main PDF'),
      ...additionalPdfs,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MERGE PDFs',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textColor,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkBackground,
              Color(0xFF101820),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Card(
                color: AppTheme.surfaceColor,
                margin: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (allPdfs.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: PDFDropZone(
                          onPdfDropped: (files) async {
                            if (files.isEmpty || !context.mounted) return;
                            ref.read(loadingProvider.notifier).state = true;
                            try {
                              for (var i = 0; i < files.length; i++) {
                                final file = files[i];
                                final result = await pdfService.readFileAsBytes(
                                  file,
                                );
                                if (result != null) {
                                  if (i == 0) {
                                    // Set first file as main PDF
                                    ref.read(pdfDataProvider.notifier).state =
                                        result.$1;
                                    ref
                                        .read(pdfMetadataProvider.notifier)
                                        .state = result.$2;
                                  } else {
                                    // Add subsequent files to additional PDFs
                                    ref
                                        .read(additionalPdfsProvider.notifier)
                                        .update(
                                          (state) => [
                                            ...state,
                                            (result.$1, result.$2.fileName),
                                          ],
                                        );
                                  }
                                }
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${files.length} PDFs loaded successfully',
                                    ),
                                    backgroundColor: AppTheme.primaryBlue,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              ref.read(loadingProvider.notifier).state = false;
                            }
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ReorderableListView(
                              shrinkWrap: true,
                              onReorderItem: (oldIndex, newIndex) {
                                final List<(Uint8List, String)> newAllPdfs =
                                    List.from(allPdfs);
                                final item = newAllPdfs.removeAt(oldIndex);
                                newAllPdfs.insert(newIndex, item);
                                ref.read(pdfDataProvider.notifier).state =
                                    newAllPdfs[0].$1;
                                ref
                                    .read(pdfMetadataProvider.notifier)
                                    .state = PdfMetadata(
                                  pageCount: 0,
                                  fileSizeKB:
                                      (newAllPdfs[0].$1.length / 1024).round(),
                                  fileName: newAllPdfs[0].$2,
                                );
                                ref
                                    .read(additionalPdfsProvider.notifier)
                                    .state = newAllPdfs.length > 1
                                        ? newAllPdfs.sublist(1)
                                        : [];
                              },
                              children: [
                                for (int i = 0; i < allPdfs.length; i++)
                                  ListTile(
                                    key: ValueKey('pdf_${allPdfs[i].$2}_$i'),
                                    leading: Icon(
                                      Icons.picture_as_pdf,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    title: Text(
                                      allPdfs[i].$2,
                                      style: TextStyle(
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (i == 0) {
                                          // If this is the last PDF, clear everything
                                          if (additionalPdfs.isEmpty) {
                                            ref
                                                .read(pdfDataProvider.notifier)
                                                .state = null;
                                            ref
                                                .read(
                                                  pdfMetadataProvider.notifier,
                                                )
                                                .state = null;
                                          } else {
                                            // Move first additional PDF to main
                                            final firstAdditional =
                                                additionalPdfs.first;
                                            ref
                                                .read(pdfDataProvider.notifier)
                                                .state = firstAdditional.$1;
                                            ref
                                                .read(
                                                  pdfMetadataProvider.notifier,
                                                )
                                                .state = PdfMetadata(
                                              pageCount: 0,
                                              fileSizeKB:
                                                  (firstAdditional.$1.length /
                                                          1024)
                                                      .round(),
                                              fileName: firstAdditional.$2,
                                            );
                                            // Remove it from additional PDFs
                                            final newAdditionalPdfs =
                                                List<(Uint8List, String)>.from(
                                                  additionalPdfs,
                                                );
                                            newAdditionalPdfs.removeAt(0);
                                            ref
                                                .read(
                                                  additionalPdfsProvider
                                                      .notifier,
                                                )
                                                .state = newAdditionalPdfs;
                                          }
                                        } else {
                                          final newAdditionalPdfs =
                                              List<(Uint8List, String)>.from(
                                                additionalPdfs,
                                              );
                                          newAdditionalPdfs.removeAt(i - 1);
                                          ref
                                              .read(
                                                additionalPdfsProvider.notifier,
                                              )
                                              .state = newAdditionalPdfs;
                                        }
                                      },
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: Icon(Icons.add),
                              label: Text('Add More PDFs'),
                              onPressed: () async {
                                final input =
                                    html.FileUploadInputElement()
                                      ..accept = 'application/pdf'
                                      ..multiple = true;
                                input.click();
                                input.onChange.listen((event) async {
                                  if (input.files?.isNotEmpty == true) {
                                    for (var file in input.files!) {
                                      if (!context.mounted) return;
                                      final result = await pdfService
                                          .readFileAsBytes(file);
                                      if (result != null && context.mounted) {
                                        if (pdfData == null) {
                                          ref
                                              .read(pdfDataProvider.notifier)
                                              .state = result.$1;
                                          ref
                                              .read(
                                                pdfMetadataProvider.notifier,
                                              )
                                              .state = result.$2;
                                        } else {
                                          ref
                                              .read(
                                                additionalPdfsProvider.notifier,
                                              )
                                              .update(
                                                (state) => [
                                                  ...state,
                                                  (
                                                    result.$1,
                                                    result.$2.fileName,
                                                  ),
                                                ],
                                              );
                                        }
                                      }
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${input.files!.length} PDFs added successfully',
                                          ),
                                          backgroundColor: AppTheme.primaryBlue,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    if (allPdfs.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.merge_type),
                          label: Text('Merge PDFs'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: Size(200, 45),
                          ),
                          onPressed: () async {
                            if (allPdfs.length < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Add at least 2 PDFs to merge'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            ref.read(loadingProvider.notifier).state = true;
                            ref
                                .read(processingProgressProvider.notifier)
                                .state = 0.0;

                            try {
                              final pdfList =
                                  allPdfs.map((pdf) => pdf.$1).toList();

                              final result = await pdfService.mergePDFs(
                                pdfList,
                                'merged.pdf',
                                (progress) {
                                  ref
                                      .read(processingProgressProvider.notifier)
                                      .state = progress;
                                },
                              );

                              if (result != null) {
                                // Wait for final progress update before download
                                ref
                                    .read(processingProgressProvider.notifier)
                                    .state = 1.0;
                                // Download and show success message
                                pdfService.downloadPDF(
                                  result.$1,
                                  result.$2.fileName,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PDFs merged successfully'),
                                      backgroundColor: AppTheme.primaryBlue,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Unable to merge these PDFs.',
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              ref.read(loadingProvider.notifier).state = false;
                              ref
                                  .read(processingProgressProvider.notifier)
                                  .state = null;
                            }
                          },
                        ),
                      ),
                    if (progress != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: _buildProgressIndicator(progress),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
