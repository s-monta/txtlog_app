import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'database_helper.dart';
import 'screens/log_list_screen.dart';
import 'tag_repository.dart';
import 'widgets/tag_chip_row.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TextLogApp());
}

class TextLogApp extends StatelessWidget {
  const TextLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'テキスト記録',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  StreamSubscription<Uri?>? _widgetClickSubscription;
  bool _isSaving = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _widgetClickSubscription = HomeWidget.widgetClicked.listen(
      _handleWidgetLaunch,
    );
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetLaunch);
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

  void _handleWidgetLaunch(Uri? uri) {
    if (uri?.scheme != 'txtlog' || !mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DatabaseHelper.instance.insertLog(_controller.text);
      if (!mounted) {
        return;
      }
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました'), duration: Duration(seconds: 1)),
      );
      _focusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openLogList() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LogListScreen()),
    );
    // Tags may have been changed from the tag settings screen.
    _loadTags();
  }

  @override
  void dispose() {
    _widgetClickSubscription?.cancel();
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _controller.text.trim().isNotEmpty && !_isSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text('テキスト記録'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: '記録一覧',
            onPressed: _openLogList,
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
                  focusNode: _focusNode,
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
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
