import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _userDataKey = 'user_data';
  static const String _authProviderKey = 'auth_provider';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _tokenExpiryKey = 'token_expiry';

  // Save authentication tokens
  static Future<void> saveAuthTokens({
    required String? accessToken,
    required String? idToken,
    String? refreshToken,
    DateTime? expiryTime,
  }) async {
    try {
      if (accessToken != null) {
        await _storage.write(key: _accessTokenKey, value: accessToken);
      }
      
      if (idToken != null) {
        await _storage.write(key: _idTokenKey, value: idToken);
      }
      
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }
      
      if (expiryTime != null) {
        await _storage.write(
          key: _tokenExpiryKey, 
          value: expiryTime.millisecondsSinceEpoch.toString()
        );
      }
    } catch (e) {
      throw Exception('Failed to save auth tokens: $e');
    }
  }

  // Get access token for API requests
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw Exception('Failed to get access token: $e');
    }
  }

  // Get ID token
  static Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _idTokenKey);
    } catch (e) {
      throw Exception('Failed to get ID token: $e');
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString == null) return true;
      
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(expiryString)
      );
      
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true; // Assume expired on error
    }
  }

  // Save user data
  static Future<void> saveUserData({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        if (displayName != null) 'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'lastLogin': DateTime.now().toIso8601String(),
      };
      
      await _storage.write(
        key: _userDataKey, 
        value: jsonEncode(userData)
      );
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _storage.read(key: _userDataKey);
      if (userDataString == null) return null;
      
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Save auth provider type
  static Future<void> saveAuthProvider(LocalAuthProvider provider) async {
    try {
      await _storage.write(key: _authProviderKey, value: provider.name);
    } catch (e) {
      throw Exception('Failed to save auth provider: $e');
    }
  }

  // Get auth provider
  static Future<LocalAuthProvider?> getAuthProvider() async {
    try {
      final providerString = await _storage.read(key: _authProviderKey);
      if (providerString == null) return null;

      return LocalAuthProvider.values.firstWhere(
        (provider) => provider.name == providerString,
        orElse: () => LocalAuthProvider.unknown,
      );
    } catch (e) {
      return null;
    }
  }

  // Biometric settings
  static Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _biometricEnabledKey, 
        value: enabled.toString()
      );
    } catch (e) {
      throw Exception('Failed to save biometric setting: $e');
    }
  }

  static Future<bool> isBiometricEnabled() async {
    try {
      final enabledString = await _storage.read(key: _biometricEnabledKey);
      return enabledString == 'true';
    } catch (e) {
      return false;
    }
  }

  // Clear all stored data (logout)
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear stored data: $e');
    }
  }

  // Clear only auth tokens (keep user preferences)
  static Future<void> clearAuthTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _idTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenExpiryKey);
    } catch (e) {
      throw Exception('Failed to clear auth tokens: $e');
    }
  }

  // Get token for API requests (with automatic refresh if needed)
  static Future<String?> getValidToken() async {
    try {
      if (await isTokenExpired()) {
        // Try to refresh token
        final refreshed = await _refreshTokenIfNeeded();
        if (!refreshed) {
          return null; // Token refresh failed
        }
      }
      
      return await getAccessToken();
    } catch (e) {
      throw Exception('Failed to get valid token: $e');
    }
  }

  // Private method to refresh token
  static Future<bool> _refreshTokenIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      
      // Force refresh the token
      final idTokenResult = await user.getIdTokenResult(true);
      
      await saveAuthTokens(
        accessToken: idTokenResult.token,
        idToken: idTokenResult.token,
        expiryTime: idTokenResult.expirationTime,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getAccessToken();
      final user = FirebaseAuth.instance.currentUser;
      return token != null && user != null && !await isTokenExpired();
    } catch (e) {
      return false;
    }
  }
}

// Rename enum to avoid conflict with firebase_auth's AuthProvider
enum LocalAuthProvider {
  google,
  github,
  microsoft,
  emailPassword,
  biometric,
  unknown,
}