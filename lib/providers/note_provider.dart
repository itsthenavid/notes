// lib/providers/note_provider.dart

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';
import '../utils/validators.dart';

enum SortOrder { newest, oldest, alphabetical, modified, wordCount }

enum FilterType { all, pinned, favorites, archived }

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.newest;
  FilterType _filterType = FilterType.all;
  bool _isLoading = false;
  bool _initialized = false;

  final StorageService _storage = StorageService.instance;

  List<Note> get notes {
    List<Note> filtered = _filterNotes(_notes);
    filtered = _searchNotes(filtered);
    _sortNotes(filtered);
    return filtered;
  }

  List<Note> get allNotes => List.unmodifiable(_notes);

  List<Note> get pinnedNotes =>
      _notes.where((note) => note.isPinned && !note.isArchived).toList();

  List<Note> get favoriteNotes =>
      _notes.where((note) => note.isFavorite && !note.isArchived).toList();

  List<Note> get archivedNotes =>
      _notes.where((note) => note.isArchived).toList();

  String get searchQuery => _searchQuery;
  SortOrder get sortOrder => _sortOrder;
  FilterType get filterType => _filterType;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;
  int get totalNotes => _notes.length;
  int get activeNotes => _notes.where((n) => !n.isArchived).length;

  Future<void> init() async {
    if (_initialized) {
      AppLogger.warning('NoteProvider already initialized');
      return;
    }

    try {
      AppLogger.info('Initializing NoteProvider...');
      await _storage.init();
      await loadNotes();
      _loadPreferences();
      _initialized = true;
      AppLogger.success('NoteProvider initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error initializing NoteProvider', e, stackTrace);
      _initialized = false;
    }
  }

  void _loadPreferences() {
    try {
      final sortIndex =
          _storage.getValue<int>(AppConstants.storageKeySort) ?? 0;
      if (sortIndex >= 0 && sortIndex < SortOrder.values.length) {
        _sortOrder = SortOrder.values[sortIndex];
      }

      final filterIndex =
          _storage.getValue<int>(AppConstants.storageKeyFilter) ?? 0;
      if (filterIndex >= 0 && filterIndex < FilterType.values.length) {
        _filterType = FilterType.values[filterIndex];
      }

      AppLogger.info(
          'Preferences loaded: sort=$_sortOrder, filter=$_filterType');
    } catch (e) {
      AppLogger.error('Error loading preferences', e);
    }
  }

  Future<void> _savePreferences() async {
    try {
      await _storage.setValue(AppConstants.storageKeySort, _sortOrder.index);
      await _storage.setValue(AppConstants.storageKeyFilter, _filterType.index);
      AppLogger.debug('Preferences saved');
    } catch (e) {
      AppLogger.error('Error saving preferences', e);
    }
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      AppLogger.info('Loading notes from storage...');
      _notes = await _storage.loadNotes();
      AppLogger.success('Loaded ${_notes.length} notes');

      final warning = Validators.validateNoteCount(_notes.length);
      if (warning != null) {
        AppLogger.warning(warning);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading notes', e, stackTrace);
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveNotes() async {
    try {
      final success = await _storage.saveNotes(_notes);
      if (success) {
        AppLogger.debug('Notes saved successfully');
      } else {
        AppLogger.warning('Failed to save notes');
      }
      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Error saving notes', e, stackTrace);
      return false;
    }
  }

  Future<bool> addNote(Note note) async {
    try {
      final titleValidation = Validators.validateTitle(note.title);
      final contentValidation = Validators.validateContent(note.content);

      if (titleValidation != null) {
        AppLogger.warning('Invalid title: $titleValidation');
        return false;
      }

      if (contentValidation != null) {
        AppLogger.warning('Invalid content: $contentValidation');
        return false;
      }

      _notes.insert(0, note);
      final success = await saveNotes();

      if (success) {
        AppLogger.success('Note added: ${note.id}');
        notifyListeners();
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Error adding note', e, stackTrace);
      return false;
    }
  }

  Future<bool> updateNote(Note note) async {
    try {
      final titleValidation = Validators.validateTitle(note.title);
      final contentValidation = Validators.validateContent(note.content);

      if (titleValidation != null || contentValidation != null) {
        AppLogger.warning('Invalid note data');
        return false;
      }

      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
        final success = await saveNotes();

        if (success) {
          AppLogger.info('Note updated: ${note.id}');
          notifyListeners();
        }

        return success;
      }

      AppLogger.warning('Note not found for update: ${note.id}');
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating note', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteNote(String id) async {
    try {
      final initialLength = _notes.length;
      _notes.removeWhere((note) => note.id == id);

      if (_notes.length < initialLength) {
        final success = await saveNotes();

        if (success) {
          AppLogger.info('Note deleted: $id');
          notifyListeners();
        }

        return success;
      }

      AppLogger.warning('Note not found for deletion: $id');
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting note', e, stackTrace);
      return false;
    }
  }

  Future<bool> deleteNotes(List<String> ids) async {
    try {
      final initialLength = _notes.length;
      _notes.removeWhere((note) => ids.contains(note.id));

      if (_notes.length < initialLength) {
        final success = await saveNotes();
        final deletedCount = initialLength - _notes.length;

        if (success) {
          AppLogger.info('$deletedCount notes deleted');
          notifyListeners();
        }

        return success;
      }

      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting multiple notes', e, stackTrace);
      return false;
    }
  }

  Future<bool> togglePin(String id) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] =
            _notes[index].copyWith(isPinned: !_notes[index].isPinned);
        final success = await saveNotes();

        if (success) {
          AppLogger.debug('Note pin toggled: $id');
          notifyListeners();
        }

        return success;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling pin', e, stackTrace);
      return false;
    }
  }

  Future<bool> toggleFavorite(String id) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] =
            _notes[index].copyWith(isFavorite: !_notes[index].isFavorite);
        final success = await saveNotes();

        if (success) {
          AppLogger.debug('Note favorite toggled: $id');
          notifyListeners();
        }

        return success;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error toggling favorite', e, stackTrace);
      return false;
    }
  }

  Future<bool> archiveNote(String id) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(isArchived: true);
        final success = await saveNotes();

        if (success) {
          AppLogger.info('Note archived: $id');
          notifyListeners();
        }

        return success;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error archiving note', e, stackTrace);
      return false;
    }
  }

  Future<bool> unarchiveNote(String id) async {
    try {
      final index = _notes.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(isArchived: false);
        final success = await saveNotes();

        if (success) {
          AppLogger.info('Note unarchived: $id');
          notifyListeners();
        }

        return success;
      }
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Error unarchiving note', e, stackTrace);
      return false;
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      AppLogger.debug('Search query: $query');
      notifyListeners();
    }
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      AppLogger.debug('Search cleared');
      notifyListeners();
    }
  }

  Future<void> setSortOrder(SortOrder order) async {
    if (_sortOrder != order) {
      _sortOrder = order;
      await _savePreferences();
      AppLogger.info('Sort order changed: $order');
      notifyListeners();
    }
  }

  Future<void> setFilterType(FilterType type) async {
    if (_filterType != type) {
      _filterType = type;
      await _savePreferences();
      AppLogger.info('Filter type changed: $type');
      notifyListeners();
    }
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      AppLogger.warning('Note not found: $id');
      return null;
    }
  }

  bool noteExists(String id) {
    return _notes.any((note) => note.id == id);
  }

  List<Note> _filterNotes(List<Note> notes) {
    switch (_filterType) {
      case FilterType.pinned:
        return notes.where((n) => n.isPinned && !n.isArchived).toList();
      case FilterType.favorites:
        return notes.where((n) => n.isFavorite && !n.isArchived).toList();
      case FilterType.archived:
        return notes.where((n) => n.isArchived).toList();
      case FilterType.all:
        return notes.where((n) => !n.isArchived).toList();
    }
  }

  List<Note> _searchNotes(List<Note> notes) {
    if (_searchQuery.trim().isEmpty) return notes;
    final lowerQuery = _searchQuery.toLowerCase().trim();
    return notes.where((note) => note.matches(lowerQuery)).toList();
  }

  void _sortNotes(List<Note> notes) {
    final pinnedNotes = notes.where((n) => n.isPinned).toList();
    final unpinnedNotes = notes.where((n) => !n.isPinned).toList();

    _applySorting(pinnedNotes);
    _applySorting(unpinnedNotes);

    notes.clear();
    notes.addAll([...pinnedNotes, ...unpinnedNotes]);
  }

  void _applySorting(List<Note> notes) {
    switch (_sortOrder) {
      case SortOrder.newest:
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOrder.oldest:
        notes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case SortOrder.alphabetical:
        notes.sort((a, b) {
          final aTitle = a.title.isEmpty ? 'Untitled' : a.title;
          final bTitle = b.title.isEmpty ? 'Untitled' : b.title;
          return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
        });
        break;
      case SortOrder.modified:
        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOrder.wordCount:
        notes.sort((a, b) => b.wordCount.compareTo(a.wordCount));
        break;
    }
  }

  Future<void> clearAllNotes() async {
    try {
      _notes.clear();
      await saveNotes();
      AppLogger.warning('All notes cleared');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error clearing all notes', e, stackTrace);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      _sortOrder = SortOrder.newest;
      _filterType = FilterType.all;
      _searchQuery = '';
      await _savePreferences();
      AppLogger.info('Settings reset to defaults');
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Error resetting to defaults', e, stackTrace);
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      AppLogger.info('Exporting data...');
      await _storage.exportData();

      final data = {
        'version': AppConstants.appVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'notes': _notes.map((note) => note.toJson()).toList(),
        'settings': {
          'sortOrder': _sortOrder.index,
          'filterType': _filterType.index,
        },
      };

      AppLogger.success('Data exported successfully');
      return data;
    } catch (e, stackTrace) {
      AppLogger.error('Error exporting data', e, stackTrace);
      return {};
    }
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      AppLogger.info('Importing data...');
      final success = await _storage.importData(data);

      if (success) {
        await loadNotes();
        _loadPreferences();
        AppLogger.success('Data imported successfully');
      }

      return success;
    } catch (e, stackTrace) {
      AppLogger.error('Error importing data', e, stackTrace);
      return false;
    }
  }
}
