// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadText(String content, String filename) {
  final blob = html.Blob([content], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}

void pickCsvFile({
  required void Function(List<Map<String, String>>) onParsed,
  required void Function(String) onError,
}) {
  final input = html.FileUploadInputElement()
    ..accept = '.csv,text/csv';
  input.onChange.listen((_) {
    final file = input.files?.first;
    if (file == null) { onError('파일을 선택하지 않았습니다'); return; }
    final reader = html.FileReader();
    reader.onLoadEnd.listen((_) {
      try {
        final text = reader.result as String;
        onParsed(_parseCsv(text));
      } catch (e) {
        onError(e.toString());
      }
    });
    reader.readAsText(file, 'UTF-8');
  });
  input.click();
}

List<Map<String, String>> _parseCsv(String text) {
  // BOM 제거
  final clean = text.startsWith('\uFEFF') ? text.substring(1) : text;
  final lines = clean.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  if (lines.isEmpty) return [];
  final headers = _splitLine(lines[0]);
  final result = <Map<String, String>>[];
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final values = _splitLine(line);
    final row = <String, String>{};
    for (int j = 0; j < headers.length; j++) {
      row[headers[j]] = j < values.length ? values[j] : '';
    }
    result.add(row);
  }
  return result;
}

List<String> _splitLine(String line) {
  final result = <String>[];
  final buf = StringBuffer();
  bool inQ = false;
  for (int i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch == '"') {
      if (inQ && i + 1 < line.length && line[i + 1] == '"') { buf.write('"'); i++; }
      else { inQ = !inQ; }
    } else if (ch == ',' && !inQ) {
      result.add(buf.toString().trim()); buf.clear();
    } else {
      buf.write(ch);
    }
  }
  result.add(buf.toString().trim());
  return result;
}
