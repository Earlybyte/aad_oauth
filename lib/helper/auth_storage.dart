import 'dart:async';
import 'package:aad_oauth/model/token.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static AuthStorage shared = AuthStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  final String _tokenIdentifier;
  final Token emptyToken = Token();

  AuthStorage({String tokenIdentifier = 'Token'})
      : _tokenIdentifier = tokenIdentifier;

  Future<void> saveTokenToCache(Token token) async {
    var data = Token.toJsonMap(token);
    var json = jsonEncode(data);
    await .write(key: _tokenIdentifier, value: json);
  }

  Future<T> loadTokenFromCache<T extends Token>() async {
    try {
      var json = await _secureStorage.read(key: _tokenIdentifier);
      if (json == null) return emptyToken as FutureOr<T>;
      var data = jsonDecode(json);
      return _getTokenFromMap<T>(data) as FutureOr<T>;
    } catch (exception) {
      if (kDebugMode) {
        print(exception);
      }
      return emptyToken as FutureOr<T>;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic> data) =>
      Token.fromJson(data);

  Future clear() async {
    await _secureStorage.delete(key: _tokenIdentifier);
  }
}
