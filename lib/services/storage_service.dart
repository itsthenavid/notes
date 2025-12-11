// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';
import '../constants/app_constants.dart';

class StorageService {
  StorageService._();

  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  Future<List<Note>> loadNotes() async {
    try {
      final notesJson = prefs.getString(AppConstants.storageKeyNotes);
      if (notesJson == null || notesJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(notesJson);
      return decoded
          .map((json) => Note.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveNotes(List<Note> notes) async {
    try {
      final encoded = jsonEncode(notes.map((note) => note.toJson()).toList());
      return await prefs.setString(AppConstants.storageKeyNotes, encoded);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearNotes() async {
    try {
      return await prefs.remove(AppConstants.storageKeyNotes);
    } catch (e) {
      return false;
    }
  }

  T? getValue<T>(String key) {
    try {
      final value = prefs.get(key);
      if (value is T) return value;
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> setValue<T>(String key, T value) async {
    try {
      if (value is String) {
        return await prefs.setString(key, value);
      } else if (value is int) {
        return await prefs.setInt(key, value);
      } else if (value is double) {
        return await prefs.setDouble(key, value);
      } else if (value is bool) {
        return await prefs.setBool(key, value);
      } else if (value is List<String>) {
        return await prefs.setStringList(key, value);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeValue(String key) async {
    try {
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      return await prefs.clear();
    } catch (e) {
      return false;
    }
  }

  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  Set<String> getAllKeys() {
    return prefs.getKeys();
  }

  Future<void> exportData() async {
    await loadNotes();
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['notes'] is List) {
        final notes = (data['notes'] as List)
            .map((json) => Note.fromJson(json as Map<String, dynamic>))
            .toList();
        await saveNotes(notes);
      }

      if (data['settings'] is Map) {
        final settings = data['settings'] as Map<String, dynamic>;
        if (settings['sortOrder'] != null) {
          await setValue(
              AppConstants.storageKeySort, settings['sortOrder'] as int);
        }
        if (settings['filterType'] != null) {
          await setValue(
              AppConstants.storageKeyFilter, settings['filterType'] as int);
        }
        if (settings['themeMode'] != null) {
          await setValue(
              AppConstants.storageKeyTheme, settings['themeMode'] as String);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
