import 'dart:async';
import 'package:flutter/services.dart';
import 'package:aad_oauth/model/token.dart';
import "dart:convert" as Convert;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String _identifier = "Token";

  Future<void> saveTokenToCache(Token token) async {
    var data = Token.toJsonMap(token);
    var json = Convert.jsonEncode(data);
    await _secureStorage.write(key:_identifier, value: json);
  }

  Future<T> loadTokenToCache<T extends Token>() async {
    String json;
    try {
      json = await _secureStorage.read(key:_identifier);
    } on PlatformException catch (_) {
      // We may not be able to read the storage - if not
      // just continue as if there was none
      // This deals with Android secure storage decryption
      // problems after a fresh uninstall/reinstall
    }

    if (json == null) return null;
    try {
      var data = Convert.jsonDecode(json);
      return _getTokenFromMap<T>(data);
    } catch (exception) {
      print(exception);
      return null;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic> data) =>
      Token.fromJson(data);

  Future clear() async {
    _secureStorage.delete(key:_identifier);
  }
}
