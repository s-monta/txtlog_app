import 'package:flutter/material.dart';

import '../database_helper.dart';
import '../models/log_entry.dart';
import '../tag_repository.dart';
import '../widgets/tag_chip_row.dart';

class LogEditScreen extends StatefulWidget {
  const LogEditScreen({super.key, required this.log});

  final LogEntry log;

  @override
  State<LogEditScreen> createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  late final TextEditingController _controller;
  List<String> _tags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.log.content)
      ..addListener(_onTextChanged);
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await TagRepository.instance.loadTags();
    if (mounted) {
      setState(() {
        _tags = tags;
      });
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty || _isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      await DatabaseHelper.instance.updateLog(widget.log.id, _controller.text);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('更新しました'), duration: Duration(seconds: 1)),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除しますか?'),
        content: const Text('この記録を削除すると元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await DatabaseHelper.instance.deleteLog(widget.log.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _controller.text.trim().isNotEmpty && !_isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('記録を編集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'テキストを入力',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TagChipRow(tags: _tags, controller: _controller),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canSave ? _save : null,
                child: const Text('更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
