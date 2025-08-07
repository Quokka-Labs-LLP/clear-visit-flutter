abstract class SharedPreferenceBaseService {
  Future initialize();

  Future setAttribute<T>(String key, T value);

  Future<T> getAttribute<T>(String key, T defaultValue);

  Future deleteAttribute(String key);

  Future<bool> clearPreferences();
}
