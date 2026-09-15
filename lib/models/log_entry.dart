class LogEntry {
  const LogEntry({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String content;
  final String createdAt;
  final String updatedAt;

  factory LogEntry.fromMap(Map<String, Object?> map) {
    final createdAt = map['created_at'] as String;
    return LogEntry(
      id: map['id'] as int,
      content: map['content'] as String,
      createdAt: createdAt,
      // Rows created before the updated_at column existed have no value yet.
      updatedAt: (map['updated_at'] as String?) ?? createdAt,
    );
  }
}
