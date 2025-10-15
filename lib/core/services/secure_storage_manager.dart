import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';


class SecureStorageManager {
  static final _secureStorage = FlutterSecureStorage();
  static late final Encrypter _encrypter;
  static late final IV _iv;

  // مفاتيح التخزين الآمن
  //static const String _encryptionKeyKey = 'app_encryption_key';
  //static const String _encryptionIvKey = 'app_encryption_iv';
  
  // مفاتيح البيانات الحساسة
  static const String _adMobAppIdKey = 'encrypted_admob_app_id';
  static const String _adMobBannerIdKey = 'encrypted_admob_banner_id';
  //static const String _apiKeyKey = 'encrypted_api_key';
  //static const String _syncTokenKey = 'encrypted_sync_token';

  static Future<void> init() async {
    await _initializeEncryption();
  }

  static Future<void> _initializeEncryption() async {
    // ... (نفس كود التهيئة الآمن السابق)
  }

  /// 🔐 حفظ مفاتيح الإعلانات مشفرة
  static Future<void> saveAdKeys(String appId, String bannerId) async {
    await _secureStorage.write(key: _adMobAppIdKey, value: _encrypt(appId));
    await _secureStorage.write(key: _adMobBannerIdKey, value: _encrypt(bannerId));
  }

  /// 🔓 استرجاع مفاتيح الإعلانات
  static Future<String?> getAdMobAppId() async {
    final encrypted = await _secureStorage.read(key: _adMobAppIdKey);
    return encrypted != null ? _decrypt(encrypted) : null;
  }

  static Future<String?> getAdMobBannerId() async {
    final encrypted = await _secureStorage.read(key: _adMobBannerIdKey);
    return encrypted != null ? _decrypt(encrypted) : null;
  }

  // دوال التشفير/فك التشفير
  static String _encrypt(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }

  static String _decrypt(String encryptedData) {
    final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
    return decrypted;
  }
}