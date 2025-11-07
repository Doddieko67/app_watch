import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data (API keys, tokens, etc.)
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _geminiApiKeyKey = 'gemini_api_key';

  /// Save Gemini API key
  static Future<void> saveGeminiApiKey(String key) async {
    await _storage.write(key: _geminiApiKeyKey, value: key);
  }

  /// Get Gemini API key
  static Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: _geminiApiKeyKey);
  }

  /// Delete Gemini API key
  static Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: _geminiApiKeyKey);
  }

  /// Check if Gemini API key exists
  static Future<bool> hasGeminiApiKey() async {
    final key = await getGeminiApiKey();
    return key != null && key.isNotEmpty;
  }

  /// Delete all stored data
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
