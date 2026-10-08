import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_html/html.dart' as html;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:ui';

final pdfServiceProvider = Provider((ref) => PDFService());

class PdfMetadata {
  final int pageCount;
  final int fileSizeKB;
  final String fileName;

  PdfMetadata({
    required this.pageCount,
    required this.fileSizeKB,
    required this.fileName,
  });
}

class PDFService {
  Future<(Uint8List, PdfMetadata)?> readFileAsBytes(html.File file) async {
    try {
      if (file.type.isNotEmpty && file.type != 'application/pdf') return null;
      if (file.size > 100 * 1024 * 1024) return null;

      final reader = html.FileReader();
      final loaded = reader.onLoad.first;
      reader.readAsArrayBuffer(file);
      await loaded;
      final bytes = Uint8List.view((reader.result as ByteBuffer));
      final document = PdfDocument(inputBytes: bytes);
      try {
        return (
          bytes,
          PdfMetadata(
            pageCount: document.pages.count,
            fileSizeKB: (bytes.length / 1024).round(),
            fileName: file.name,
          ),
        );
      } finally {
        document.dispose();
      }
    } catch (e) {
      return null;
    }
  }

  Future<(Uint8List, PdfMetadata)?> mergePDFs(
    List<Uint8List> pdfList,
    String fileName, [
    void Function(double)? onProgress,
  ]) async {
    try {
      if (pdfList.length < 2) return null;
      onProgress?.call(0.0);

      final output = PdfDocument();
      var processedPages = 0;
      final documents = <PdfDocument>[];
      try {
        for (final bytes in pdfList) {
          documents.add(PdfDocument(inputBytes: bytes));
        }
        final totalPages = documents.fold<int>(
          0,
          (total, document) => total + document.pages.count,
        );
        if (totalPages == 0) return null;

        output.pageSettings.margins.all = 0;
        if (output.pages.count > 0) output.pages.removeAt(0);

        for (final source in documents) {
          for (var index = 0; index < source.pages.count; index++) {
            final sourcePage = source.pages[index];
            final target = output.pages.insert(
              output.pages.count,
              sourcePage.size,
              null,
              sourcePage.rotation,
            );
            target.graphics.drawPdfTemplate(
              sourcePage.createTemplate(),
              Offset.zero,
              sourcePage.size,
            );
            onProgress?.call(++processedPages / totalPages);
          }
        }

        final resultBytes = Uint8List.fromList(output.saveSync());
        return (
          resultBytes,
          PdfMetadata(
            pageCount: processedPages,
            fileSizeKB: (resultBytes.length / 1024).round(),
            fileName: fileName,
          ),
        );
      } finally {
        for (final document in documents) {
          document.dispose();
        }
        output.dispose();
        onProgress?.call(1.0);
      }
    } catch (e) {
      return null;
    }
  }

  Future<(Uint8List, PdfMetadata)?> splitPDF(
    Uint8List pdfBytes,
    List<int> pageNumbers,
    String fileName, [
    void Function(double)? onProgress,
  ]) async {
    try {
      onProgress?.call(0.0);

      final PdfDocument inputDocument = PdfDocument(inputBytes: pdfBytes);
      final PdfDocument outputDocument = PdfDocument();
      try {
        if (outputDocument.pages.count > 0) outputDocument.pages.removeAt(0);
        final pages =
            pageNumbers
                .where(
                  (number) => number > 0 && number <= inputDocument.pages.count,
                )
                .toSet()
                .toList()
              ..sort();
        if (pages.isEmpty) return null;

        for (var index = 0; index < pages.length; index++) {
          final sourcePage = inputDocument.pages[pages[index] - 1];
          final target = outputDocument.pages.insert(
            outputDocument.pages.count,
            sourcePage.size,
            null,
            sourcePage.rotation,
          );
          target.graphics.drawPdfTemplate(
            sourcePage.createTemplate(),
            Offset.zero,
            sourcePage.size,
          );
          onProgress?.call((index + 1) / pages.length);
        }

        final resultBytes = Uint8List.fromList(outputDocument.saveSync());
        return (
          resultBytes,
          PdfMetadata(
            pageCount: pages.length,
            fileSizeKB: (resultBytes.length / 1024).round(),
            fileName: 'split_$fileName',
          ),
        );
      } finally {
        inputDocument.dispose();
        outputDocument.dispose();
        onProgress?.call(1.0);
      }
    } catch (e) {
      return null;
    }
  }

  void downloadPDF(Uint8List bytes, String fileName) {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      Future<void>.delayed(const Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });
    } catch (_) {
      // The browser may block downloads initiated outside a user gesture.
    }
  }
}
