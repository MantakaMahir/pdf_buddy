import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_buddy/components/pdf_drop_zone.dart';
import 'package:pdf_buddy/services/pdf_service.dart';
import 'package:pdf_buddy/utils/theme.dart';
import 'package:pdf_buddy/providers/processing_providers.dart';
import 'package:pdf_buddy/providers.dart';

class PageRange {
  final int start;
  final int end;

  PageRange(this.start, this.end);

  List<int> getPages() {
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  String toString() => '$start-$end';
}

final pageRangesProvider = StateProvider<List<PageRange>>((ref) => []);

class SplitPDFPage extends ConsumerWidget {
  const SplitPDFPage({super.key});

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
            progress < 1.0 ? 'Splitting PDF...' : 'Finalizing...',
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

  bool _isValidRange(String start, String end, int totalPages) {
    try {
      final startPage = int.parse(start);
      final endPage = int.parse(end);
      return startPage >= 1 && endPage <= totalPages && startPage <= endPage;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = ref.watch(pdfServiceProvider);
    final pdfData = ref.watch(pdfDataProvider);
    final metadata = ref.watch(pdfMetadataProvider);
    final pageRanges = ref.watch(pageRangesProvider);
    final progress = ref.watch(processingProgressProvider);

    final allSelectedPages =
        pageRanges.expand((range) => range.getPages()).toList()..sort();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SPLIT PDF',
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
                    if (pdfData == null)
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: PDFDropZone(
                          allowMultiple: false,
                          onPdfDropped: (files) async {
                            if (files.isEmpty || !context.mounted) return;
                            ref.read(loadingProvider.notifier).state = true;
                            try {
                              final result = await pdfService.readFileAsBytes(
                                files[0],
                              );
                              if (result != null && context.mounted) {
                                ref.read(pdfDataProvider.notifier).state =
                                    result.$1;
                                ref.read(pdfMetadataProvider.notifier).state =
                                    result.$2;
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'PDF loaded successfully',
                                      ),
                                      backgroundColor: AppTheme.primaryBlue,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not read this PDF. Check the file and try again.',
                                    ),
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
                            // PDF Name and Info with Remove Button
                            if (metadata != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Column(
                                      children: [
                                        Text(
                                          metadata.fileName,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color: AppTheme.textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '${metadata.pageCount} pages • ${(metadata.fileSizeKB / 1024).toStringAsFixed(2)} MB',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.textColor
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: Icon(Icons.delete),
                                label: Text('Remove PDF'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  ref.read(pdfDataProvider.notifier).state =
                                      null;
                                  ref.read(pdfMetadataProvider.notifier).state =
                                      null;
                                  ref.read(pageRangesProvider.notifier).state =
                                      [];
                                },
                              ),
                              SizedBox(height: 24),
                              Divider(
                                color: AppTheme.primaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              SizedBox(height: 24),
                            ],

                            // Page Ranges List
                            if (pageRanges.isNotEmpty) ...[
                              Text(
                                'Selected Ranges (drag to reorder)',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: AppTheme.textColor),
                              ),
                              SizedBox(height: 16),
                              ReorderableListView(
                                shrinkWrap: true,
                                onReorderItem: (oldIndex, newIndex) {
                                  final ranges = List<PageRange>.from(
                                    pageRanges,
                                  );
                                  final item = ranges.removeAt(oldIndex);
                                  ranges.insert(newIndex, item);
                                  ref.read(pageRangesProvider.notifier).state =
                                      ranges;
                                },
                                children: [
                                  for (int i = 0; i < pageRanges.length; i++)
                                    ListTile(
                                      key: ValueKey('range_$i'),
                                      title: Text(
                                        'Pages ${pageRanges[i]}',
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
                                          final ranges = List<PageRange>.from(
                                            pageRanges,
                                          );
                                          ranges.removeAt(i);
                                          ref
                                              .read(pageRangesProvider.notifier)
                                              .state = ranges;
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 24),
                            ],

                            // Add Range Section
                            if (metadata != null) ...[
                              SizedBox(height: pageRanges.isEmpty ? 0 : 24),
                              Text(
                                'Add Page Range',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(color: AppTheme.textColor),
                              ),
                              SizedBox(height: 16),
                              StatefulBuilder(
                                builder: (context, setState) {
                                  final startController =
                                      TextEditingController();
                                  final endController = TextEditingController();

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller: startController,
                                          decoration: InputDecoration(
                                            labelText: 'Start Page',
                                            labelStyle: TextStyle(
                                              color: AppTheme.textColor,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBlue
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: AppTheme.textColor,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        'to',
                                        style: TextStyle(
                                          color: AppTheme.textColor,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller: endController,
                                          decoration: InputDecoration(
                                            labelText: 'End Page',
                                            labelStyle: TextStyle(
                                              color: AppTheme.textColor,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBlue
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppTheme.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: AppTheme.textColor,
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle,
                                          color: AppTheme.primaryBlue,
                                        ),
                                        onPressed: () {
                                          if (_isValidRange(
                                            startController.text,
                                            endController.text,
                                            metadata.pageCount,
                                          )) {
                                            final start = int.parse(
                                              startController.text,
                                            );
                                            final end = int.parse(
                                              endController.text,
                                            );
                                            final ranges = List<PageRange>.from(
                                              pageRanges,
                                            );
                                            ranges.add(PageRange(start, end));
                                            ref
                                                .read(
                                                  pageRangesProvider.notifier,
                                                )
                                                .state = ranges;
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Invalid page range',
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Icon(Icons.call_split),
                              label: Text('Split PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: Size(200, 45),
                              ),
                              onPressed:
                                  allSelectedPages.isEmpty
                                      ? null
                                      : () async {
                                        ref
                                            .read(loadingProvider.notifier)
                                            .state = true;
                                        ref
                                            .read(
                                              processingProgressProvider
                                                  .notifier,
                                            )
                                            .state = 0.0;

                                        try {
                                          final result = await pdfService
                                              .splitPDF(
                                                pdfData,
                                                allSelectedPages,
                                                metadata?.fileName ??
                                                    'split.pdf',
                                                (progress) {
                                                  ref
                                                      .read(
                                                        processingProgressProvider
                                                            .notifier,
                                                      )
                                                      .state = progress;
                                                },
                                              );
                                          if (result != null) {
                                            pdfService.downloadPDF(
                                              result.$1,
                                              result.$2.fileName,
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'PDF split successfully',
                                                  ),
                                                  backgroundColor:
                                                      AppTheme.primaryBlue,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } else if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'No valid pages could be extracted.',
                                                ),
                                              ),
                                            );
                                          }
                                        } finally {
                                          ref
                                              .read(loadingProvider.notifier)
                                              .state = false;
                                          ref
                                              .read(
                                                processingProgressProvider
                                                    .notifier,
                                              )
                                              .state = null;
                                        }
                                      },
                            ),
                            if (progress != null)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: _buildProgressIndicator(progress),
                              ),
                          ],
                        ),
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
