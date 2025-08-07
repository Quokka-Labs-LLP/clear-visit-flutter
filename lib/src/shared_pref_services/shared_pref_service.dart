import 'package:base_architecture/src/shared_pref_services/shared_pref_base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService extends SharedPreferenceBaseService {
  late final SharedPreferences _sharedPreferenceInstance;

  @override
  Future<T> getAttribute<T>(String key, T defaultValue) async {
    switch (T) {
      case int:
        return (_sharedPreferenceInstance.getInt(key) ?? defaultValue) as T;
      case bool:
        return (_sharedPreferenceInstance.getBool(key) ?? defaultValue) as T;
      case double:
        return (_sharedPreferenceInstance.getDouble(key) ?? defaultValue) as T;
      case String:
        return (_sharedPreferenceInstance.getString(key) ?? defaultValue) as T;
      default: return defaultValue;
    }
  }

  @override
  Future setAttribute<T>(String key, T value) async {
    if (value is int?) {
      if (value != null) {
        await _sharedPreferenceInstance.setInt(key, value);
      }
    } else if (value is int) {
      await _sharedPreferenceInstance.setInt(key, value);
    } else if (value is bool?) {
      if (value != null) {
        await _sharedPreferenceInstance.setBool(key, value);
      }
    } else if (value is bool) {
      await _sharedPreferenceInstance.setBool(key, value);
    } else if (value is double?) {
      if (value != null) {
        await _sharedPreferenceInstance.setDouble(key, value);
      }
    } else if (value is double) {
      await _sharedPreferenceInstance.setDouble(key, value);
    } else if (value is String?) {
      if (value != null) {
        await _sharedPreferenceInstance.setString(key, value);
      }
    } else if (value is String) {
      await _sharedPreferenceInstance.setString(key, value);
    } else {
      throw Exception('unrecognized data type $T');
    }
  }

  @override
  Future initialize() async {
    _sharedPreferenceInstance = await SharedPreferences.getInstance();
  }

  @override
  Future deleteAttribute(String key) async {
    await _sharedPreferenceInstance.remove(key);
  }

  @override
  Future<bool> clearPreferences() async {
    return await _sharedPreferenceInstance.clear();
  }
}
