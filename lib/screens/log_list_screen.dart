import 'package:flutter/material.dart';

import '../csv_exporter.dart';
import '../database_helper.dart';
import '../models/log_entry.dart';
import 'log_edit_screen.dart';
import 'tag_settings_screen.dart';

class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  List<LogEntry> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await DatabaseHelper.instance.getAllLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLog(LogEntry log) async {
    setState(() {
      _logs.removeWhere((l) => l.id == log.id);
    });
    await DatabaseHelper.instance.deleteLog(log.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('削除しました'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () async {
            await DatabaseHelper.instance.insertLog(log.content);
            _loadLogs();
          },
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エクスポートするデータがありません')),
      );
      return;
    }
    await CsvExporter.shareAsCsv(_logs);
  }

  Future<void> _openTagSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TagSettingsScreen()),
    );
  }

  Future<void> _openEditScreen(LogEntry log) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LogEditScreen(log: log)),
    );
    _loadLogs();
  }

  String _formatDateTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) {
      return iso;
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記録一覧'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sell_outlined),
            tooltip: 'タグ管理',
            onPressed: _openTagSettings,
          ),
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'CSVエクスポート',
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text('まだ記録がありません'))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Dismissible(
                  key: ValueKey(log.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) => _deleteLog(log),
                  child: ListTile(
                    title: Text(
                      log.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(_formatDateTime(log.updatedAt)),
                    onTap: () => _openEditScreen(log),
                  ),
                );
              },
            ),
    );
  }
}
