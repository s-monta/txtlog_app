import 'package:flutter_test/flutter_test.dart';
import 'package:txtlog_app/widgets/tag_chip_row.dart';

void main() {
  group('TagChipRow.toggleTag', () {
    test('空欄にタグを追加すると末尾に付与される', () {
      final result = TagChipRow.toggleTag('', '頭痛');
      expect(result, '#頭痛\n');
    });

    test('既存テキストがあれば改行してから末尾に付与される', () {
      final result = TagChipRow.toggleTag('体調メモ', '頭痛');
      expect(result, '体調メモ\n#頭痛\n');
    });

    test('末尾に既に改行がある場合は改行を重ねない', () {
      final result = TagChipRow.toggleTag('体調メモ\n', '頭痛');
      expect(result, '体調メモ\n#頭痛\n');
    });

    test('既にタグ行があれば削除される(トグル)', () {
      final result = TagChipRow.toggleTag('体調メモ\n#頭痛\n', '頭痛');
      expect(result, '体調メモ\n');
    });

    test('本文途中のタグ行も削除できる', () {
      final result = TagChipRow.toggleTag('前\n#頭痛\n後', '頭痛');
      expect(result, '前\n後');
    });
  });

  group('TagChipRow.isTagActive', () {
    test('タグ行が存在すればtrue', () {
      expect(TagChipRow.isTagActive('メモ\n#頭痛\n', '頭痛'), isTrue);
    });

    test('タグ行が存在しなければfalse', () {
      expect(TagChipRow.isTagActive('メモ', '頭痛'), isFalse);
    });

    test('部分一致では反応しない', () {
      expect(TagChipRow.isTagActive('メモ #頭痛です', '頭痛'), isFalse);
    });
  });
}
