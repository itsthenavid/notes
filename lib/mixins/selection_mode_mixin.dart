// lib/mixins/selection_mode_mixin.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';

mixin SelectionModeMixin<T extends StatefulWidget> on State<T> {
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedNoteIds.length;

  bool isNoteSelected(String noteId) => _selectedNoteIds.contains(noteId);

  void toggleSelectionMode(String? noteId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (_isSelectionMode) {
        if (noteId != null) _selectedNoteIds.add(noteId);
      } else {
        _selectedNoteIds.clear();
      }
    });
  }

  void toggleNoteSelection(String noteId) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) toggleSelectionMode(null);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void cancelSelection() {
    if (_isSelectionMode) toggleSelectionMode(null);
  }

  void toggleSelectAll(BuildContext context) {
    HapticFeedback.selectionClick();
    final noteProvider = context.read<NoteProvider>();
    setState(() {
      if (_selectedNoteIds.length == noteProvider.notes.length) {
        _selectedNoteIds.clear();
      } else {
        _selectedNoteIds.clear();
        _selectedNoteIds.addAll(noteProvider.notes.map((note) => note.id));
      }
    });
  }

  Future<void> deleteSelectedNotes(
    BuildContext context,
    Function(String, IconData) showSnackBar,
  ) async {
    HapticFeedback.heavyImpact();
    final noteProvider = context.read<NoteProvider>();
    final toDeleteCount = _selectedNoteIds.length;
    final success = await noteProvider.deleteNotes(_selectedNoteIds.toList());
    toggleSelectionMode(null);
    if (mounted && success) {
      showSnackBar('$toDeleteCount notes deleted', Icons.delete_rounded);
    }
  }

  Future<void> pinSelectedNotes(
    BuildContext context,
    bool shouldPin,
    Function(String, IconData) showSnackBar,
  ) async {
    HapticFeedback.mediumImpact();
    final noteProvider = context.read<NoteProvider>();
    for (final noteId in _selectedNoteIds) {
      final note = noteProvider.getNoteById(noteId);
      if (note != null && note.isPinned != shouldPin) {
        await noteProvider.togglePin(noteId);
      }
    }
    toggleSelectionMode(null);
    if (mounted) {
      showSnackBar(
        shouldPin ? 'Notes pinned' : 'Notes unpinned',
        shouldPin ? Icons.push_pin_rounded : Icons.push_pin_outlined,
      );
    }
  }
}
