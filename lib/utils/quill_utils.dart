// lib/utils/quill_utils.dart

import 'package:flutter/material.dart';
import 'dart:convert';

class QuillUtils {
  QuillUtils._();

  static TextSpan getPreviewRichText(String content, {TextStyle? baseStyle}) {
    if (content.isEmpty) {
      return TextSpan(
        text: 'No content',
        style: baseStyle?.copyWith(fontStyle: FontStyle.italic),
      );
    }

    try {
      final decoded = jsonDecode(content);
      if (decoded is List && decoded.isNotEmpty) {
        final spans = <TextSpan>[];
        for (var op in decoded) {
          if (op is Map && op.containsKey('insert')) {
            final text = op['insert']?.toString() ?? '';
            if (text.isNotEmpty) {
              final attributes = op['attributes'] as Map<String, dynamic>?;
              spans.add(_createStyledSpan(text, attributes, baseStyle));
            }
          }
        }
        return TextSpan(
          children: spans.isNotEmpty
              ? spans
              : [TextSpan(text: 'No content', style: baseStyle)],
        );
      }
    } catch (_) {
      return TextSpan(
        text: content.trim().isEmpty ? 'No content' : content.trim(),
        style: baseStyle,
      );
    }

    final trimmed = content.trim();
    return TextSpan(
      text: trimmed.isEmpty ? 'No content' : trimmed,
      style: baseStyle,
    );
  }

  static TextSpan _createStyledSpan(
    String text,
    Map<String, dynamic>? attributes,
    TextStyle? baseStyle,
  ) {
    var style = baseStyle ?? const TextStyle();

    if (attributes == null || attributes.isEmpty) {
      return TextSpan(text: text, style: style);
    }

    style = _applyBoldItalicUnderline(style, attributes);
    style = _applyStrikethrough(style, attributes);

    if (attributes['header'] != null) {
      style = _applyHeaderStyle(style, attributes, baseStyle);
    }

    if (attributes['list'] != null) {
      return _createListItem(text, style, attributes);
    }

    if (attributes['code-block'] == true) {
      style = _applyCodeBlockStyle(style, baseStyle);
    }

    if (attributes['blockquote'] == true) {
      return _createBlockquote(text, style);
    }

    if (attributes['link'] != null) {
      style = style.copyWith(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      );
    }

    return TextSpan(text: text, style: style);
  }

  static TextStyle _applyBoldItalicUnderline(
    TextStyle style,
    Map<String, dynamic> attributes,
  ) {
    if (attributes['bold'] == true) {
      style = style.copyWith(fontWeight: FontWeight.w700);
    }
    if (attributes['italic'] == true) {
      style = style.copyWith(fontStyle: FontStyle.italic);
    }
    if (attributes['underline'] == true) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    return style;
  }

  static TextStyle _applyStrikethrough(
    TextStyle style,
    Map<String, dynamic> attributes,
  ) {
    if (attributes['strike'] == true) {
      style = style.copyWith(
        decoration: TextDecoration.lineThrough,
        decorationColor: style.color?.withOpacity(0.6),
      );
    }
    return style;
  }

  static TextStyle _applyHeaderStyle(
    TextStyle style,
    Map<String, dynamic> attributes,
    TextStyle? baseStyle,
  ) {
    try {
      final headerLevel = attributes['header'] is int
          ? attributes['header'] as int
          : int.tryParse(attributes['header'].toString()) ?? 1;
      final fontSize = baseStyle?.fontSize ?? 14.0;
      final sizeMultiplier = (4 - headerLevel.clamp(1, 3)) * 2.5;
      return style.copyWith(
        fontSize: (fontSize + sizeMultiplier).clamp(14.0, 32.0),
        fontWeight: FontWeight.w700,
        height: 1.3,
      );
    } catch (_) {
      return style;
    }
  }

  static TextSpan _createListItem(
    String text,
    TextStyle style,
    Map<String, dynamic> attributes,
  ) {
    final listType = attributes['list'].toString();
    final bullet = listType == 'ordered' ? '1. ' : '• ';
    return TextSpan(
      children: [
        TextSpan(
          text: bullet,
          style: style.copyWith(fontWeight: FontWeight.w600),
        ),
        TextSpan(text: text, style: style),
      ],
    );
  }

  static TextStyle _applyCodeBlockStyle(TextStyle style, TextStyle? baseStyle) {
    return style.copyWith(
      fontFamily: 'monospace',
      backgroundColor: style.color?.withOpacity(0.1),
      fontSize: ((baseStyle?.fontSize ?? 14.0) * 0.9).clamp(10.0, 20.0),
    );
  }

  static TextSpan _createBlockquote(String text, TextStyle style) {
    return TextSpan(
      children: [
        TextSpan(
          text: '❝ ',
          style: style.copyWith(fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: text,
          style: style.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  static String extractPlainText(String content) {
    if (content.isEmpty) return '';

    try {
      final decoded = jsonDecode(content);
      if (decoded is List && decoded.isNotEmpty) {
        final buffer = StringBuffer();
        for (var op in decoded) {
          if (op is Map && op.containsKey('insert')) {
            final text = op['insert']?.toString() ?? '';
            buffer.write(text);
          }
        }
        final result = buffer.toString().trim();
        return result.isEmpty ? '' : result;
      }
    } catch (_) {
      return content.trim();
    }

    return content.trim();
  }

  static int getWordCount(String content) {
    final plainText = extractPlainText(content);
    if (plainText.isEmpty) return 0;

    return plainText
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .length;
  }

  static int getCharacterCount(String content) {
    final plainText = extractPlainText(content);
    return plainText.replaceAll(RegExp(r'\s'), '').length;
  }

  static int getCharacterCountWithSpaces(String content) {
    final plainText = extractPlainText(content);
    return plainText.length;
  }

  static int getParagraphCount(String content) {
    final plainText = extractPlainText(content);
    if (plainText.isEmpty) return 0;

    return plainText
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;
  }

  static bool hasFormatting(String content) {
    if (content.isEmpty) return false;

    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        for (var op in decoded) {
          if (op is Map && op.containsKey('attributes')) {
            final attrs = op['attributes'];
            if (attrs is Map && attrs.isNotEmpty) {
              return true;
            }
          }
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  static String stripFormatting(String content) => extractPlainText(content);

  static int getReadingTimeMinutes(String content, {int wordsPerMinute = 200}) {
    final wordCount = getWordCount(content);
    if (wordCount == 0) return 0;
    return (wordCount / wordsPerMinute).ceil();
  }

  static String getReadingTimeText(String content, {int wordsPerMinute = 200}) {
    final minutes =
        getReadingTimeMinutes(content, wordsPerMinute: wordsPerMinute);
    if (minutes < 1) return '< 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes min read';
  }

  static bool isEmpty(String content) {
    return extractPlainText(content).trim().isEmpty;
  }

  static bool isNotEmpty(String content) => !isEmpty(content);
}
