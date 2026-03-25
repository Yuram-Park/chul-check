// Non-web stub
void downloadText(String content, String filename) {}

void pickCsvFile({
  required void Function(List<Map<String, String>>) onParsed,
  required void Function(String) onError,
}) {
  onError('웹 환경에서만 지원됩니다');
}
