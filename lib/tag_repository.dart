import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user-editable list of one-touch tag buttons
/// (e.g. "頭痛", "眠気") shown on the input and edit screens.
class TagRepository {
  TagRepository._();

  static final TagRepository instance = TagRepository._();

  static const _prefsKey = 'quick_tags';
  static const _defaultTags = ['頭痛', '眠気', '気分'];

  Future<List<String>> loadTags() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == null) {
      return List.of(_defaultTags);
    }
    final decoded = jsonDecode(stored) as List<dynamic>;
    return decoded.cast<String>();
  }

  Future<void> saveTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(tags));
  }
}
