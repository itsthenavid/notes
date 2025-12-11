// lib/models/note_model.dart

import 'package:uuid/uuid.dart';
import '../extensions/string_extensions.dart';
import '../utils/quill_utils.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorIndex;
  final bool isPinned;
  final int backgroundStyle;
  final List<String> tags;
  final bool isArchived;
  final bool isFavorite;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.colorIndex = 0,
    this.isPinned = false,
    this.backgroundStyle = 0,
    this.tags = const [],
    this.isArchived = false,
    this.isFavorite = false,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorIndex': colorIndex,
      'isPinned': isPinned,
      'backgroundStyle': backgroundStyle,
      'tags': tags,
      'isArchived': isArchived,
      'isFavorite': isFavorite,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    try {
      return Note(
        id: json['id']?.toString() ?? const Uuid().v4(),
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        colorIndex: (json['colorIndex'] is int) ? json['colorIndex'] as int : 0,
        isPinned: json['isPinned'] == true,
        backgroundStyle: (json['backgroundStyle'] is int)
            ? json['backgroundStyle'] as int
            : 0,
        tags: json['tags'] is List
            ? List<String>.from((json['tags'] as List).map((e) => e.toString()))
            : [],
        isArchived: json['isArchived'] == true,
        isFavorite: json['isFavorite'] == true,
      );
    } catch (e) {
      return Note(
        title: '',
        content: '',
      );
    }
  }

  Note copyWith({
    String? title,
    String? content,
    int? colorIndex,
    bool? isPinned,
    int? backgroundStyle,
    List<String>? tags,
    bool? isArchived,
    bool? isFavorite,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      colorIndex: colorIndex ?? this.colorIndex,
      isPinned: isPinned ?? this.isPinned,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  int get wordCount => QuillUtils.getWordCount(content);

  int get characterCount => QuillUtils.getCharacterCount(content);

  String get plainContent => QuillUtils.extractPlainText(content);

  String get preview => plainContent.smartTruncate;

  bool get isEmpty => title.trim().isEmpty && plainContent.trim().isEmpty;

  bool get hasContent => !isEmpty;

  String get readingTime => plainContent.readingTimeText;

  bool matches(String query) {
    if (query.trim().isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return title.toLowerCase().contains(lowerQuery) ||
        plainContent.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Note{id: $id, title: $title, isPinned: $isPinned, '
        'isArchived: $isArchived, wordCount: $wordCount}';
  }
}
