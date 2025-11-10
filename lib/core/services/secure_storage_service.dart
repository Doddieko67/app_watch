import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  /// In debug mode, reads from .env file first, then falls back to secure storage
  /// In release mode, only uses secure storage
  static Future<String?> getGeminiApiKey() async {
    // In debug mode, try .env first
    if (kDebugMode) {
      final envKey = dotenv.env['GEMINI_API_KEY'];
      if (envKey != null && envKey.isNotEmpty && envKey != 'your_gemini_api_key_here') {
        return envKey;
      }
    }

    // Fallback to secure storage (or use it directly in release mode)
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
