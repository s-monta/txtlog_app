import 'package:flutter_test/flutter_test.dart';
import 'package:txtlog_app/csv_exporter.dart';
import 'package:txtlog_app/models/log_entry.dart';

void main() {
  group('CsvExporter.buildCsv', () {
    test('ヘッダーと各行を出力する', () {
      final csv = CsvExporter.buildCsv([
        const LogEntry(
          id: 1,
          content: '頭痛がする',
          createdAt: '2026-09-15T10:00:00.000',
          updatedAt: '2026-09-15T10:00:00.000',
        ),
      ]);

      final lines = csv.trim().split('\n');
      expect(lines[0], 'id,content,created_at,updated_at');
      expect(
        lines[1],
        '1,頭痛がする,2026-09-15T10:00:00.000,2026-09-15T10:00:00.000',
      );
    });

    test('カンマ・改行・引用符を含む本文はダブルクォートでエスケープする', () {
      final csv = CsvExporter.buildCsv([
        const LogEntry(
          id: 2,
          content: '内容,"引用"\n改行あり',
          createdAt: '2026-09-15T10:00:00.000',
          updatedAt: '2026-09-15T10:00:00.000',
        ),
      ]);

      expect(
        csv,
        contains('"内容,""引用""\n改行あり"'),
      );
    });
  });
}
