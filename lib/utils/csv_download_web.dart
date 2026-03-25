// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadCsv(String content, String filename) {
  final bom = '\uFEFF'; // UTF-8 BOM (Excel 한글 깨짐 방지)
  final blob = html.Blob([bom + content], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}
