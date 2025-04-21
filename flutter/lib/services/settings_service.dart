import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _uploadUrlKey = 'upload_url';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _urlPrefixKey = 'url_prefix';

  static final SettingsService _instance = SettingsService._internal();
  late SharedPreferences _prefs;

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSettings({
    required String uploadUrl,
    required String username,
    required String password,
    required String urlPrefix,
  }) async {
    await _prefs.setString(_uploadUrlKey, uploadUrl);
    await _prefs.setString(_usernameKey, username);
    await _prefs.setString(_passwordKey, password);
    await _prefs.setString(_urlPrefixKey, urlPrefix);
  }

  String get uploadUrl => _prefs.getString(_uploadUrlKey) ?? 'https://imgbed.com/upload';
  String get username => _prefs.getString(_usernameKey) ?? '';
  String get password => _prefs.getString(_passwordKey) ?? '';
  String get urlPrefix => _prefs.getString(_urlPrefixKey) ?? 'https://imgbed.com/i/';

  String get basicAuth {
    if (username.isEmpty || password.isEmpty) return '';
    final String credentials = '$username:$password';
    final String encoded = base64.encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
} 