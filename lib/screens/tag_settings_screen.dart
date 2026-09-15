import 'package:flutter/material.dart';

import '../tag_repository.dart';

class TagSettingsScreen extends StatefulWidget {
  const TagSettingsScreen({super.key});

  @override
  State<TagSettingsScreen> createState() => _TagSettingsScreenState();
}

class _TagSettingsScreenState extends State<TagSettingsScreen> {
  final _newTagController = TextEditingController();
  List<String> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tags = await TagRepository.instance.loadTags();
    if (mounted) {
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    }
  }

  Future<void> _persist() async {
    await TagRepository.instance.saveTags(_tags);
  }

  void _addTag() {
    var name = _newTagController.text.trim();
    if (name.isEmpty) {
      return;
    }
    if (name.startsWith('#')) {
      name = name.substring(1);
    }
    if (name.isEmpty || _tags.contains(name)) {
      _newTagController.clear();
      return;
    }
    setState(() {
      _tags.add(name);
      _newTagController.clear();
    });
    _persist();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _persist();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final tag = _tags.removeAt(oldIndex);
      _tags.insert(newIndex, tag);
    });
    _persist();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タグ管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newTagController,
                          decoration: const InputDecoration(
                            hintText: '新しいタグ名(例: 頭痛)',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTag,
                        child: const Text('追加'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _tags.isEmpty
                      ? const Center(child: Text('タグがまだありません'))
                      : ReorderableListView.builder(
                          itemCount: _tags.length,
                          // onReorder is deprecated on newer Flutter SDKs in
                          // favor of onReorderItem, but the latter doesn't
                          // exist yet on the SDK this project currently
                          // targets; keep onReorder for compatibility.
                          // ignore: deprecated_member_use
                          onReorder: _reorder,
                          itemBuilder: (context, index) {
                            final tag = _tags[index];
                            return ListTile(
                              key: ValueKey(tag),
                              leading: const Icon(Icons.drag_handle),
                              title: Text('#$tag'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeTag(tag),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
