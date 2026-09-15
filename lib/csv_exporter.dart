import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'models/log_entry.dart';

class CsvExporter {
  CsvExporter._();

  static String buildCsv(List<LogEntry> logs) {
    final buffer = StringBuffer()
      ..writeln('id,content,created_at,updated_at');
    for (final log in logs) {
      buffer.writeln([
        log.id.toString(),
        _escape(log.content),
        _escape(log.createdAt),
        _escape(log.updatedAt),
      ].join(','));
    }
    return buffer.toString();
  }

  static String _escape(String field) {
    final needsQuoting =
        field.contains(',') || field.contains('"') || field.contains('\n');
    if (!needsQuoting) {
      return field;
    }
    return '"${field.replaceAll('"', '""')}"';
  }

  /// Writes all [logs] to a temporary CSV file and opens the OS share sheet
  /// so the user can save or send it wherever they like.
  static Future<void> shareAsCsv(List<LogEntry> logs) async {
    final csv = buildCsv(logs);
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-');
    final file = File(path.join(dir.path, 'txtlog_$timestamp.csv'));
    await file.writeAsString(csv);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'テキスト記録 エクスポート',
      ),
    );
  }
}
