import 'package:flutter/material.dart';

/// Inserts or removes `#tag` lines in [controller]'s text when a chip is
/// tapped. Each tag behaves as a toggle: if a `#tag` line is already present
/// it is removed, otherwise it is appended to the end of the text.
class TagChipRow extends StatelessWidget {
  const TagChipRow({super.key, required this.tags, required this.controller});

  final List<String> tags;
  final TextEditingController controller;

  /// Whether [text] already contains a `#tag` line.
  static bool isTagActive(String text, String tag) {
    final tagLine = '#$tag';
    return text.split('\n').any((line) => line.trim() == tagLine);
  }

  /// Returns [text] with the `#tag` line removed if present, otherwise with
  /// it appended to the end.
  static String toggleTag(String text, String tag) {
    final tagLine = '#$tag';
    final lines = text.split('\n');
    final index = lines.indexWhere((line) => line.trim() == tagLine);

    if (index != -1) {
      lines.removeAt(index);
      return lines.join('\n');
    }
    return (text.isEmpty || text.endsWith('\n'))
        ? '$text$tagLine\n'
        : '$text\n$tagLine\n';
  }

  void _toggleTag(String tag) {
    final newText = toggleTag(controller.text, tag);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tag = tags[index];
          return FilterChip(
            label: Text(tag, style: const TextStyle(fontSize: 16)),
            selected: isTagActive(controller.text, tag),
            visualDensity: VisualDensity.comfortable,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onSelected: (_) => _toggleTag(tag),
          );
        },
      ),
    );
  }
}
