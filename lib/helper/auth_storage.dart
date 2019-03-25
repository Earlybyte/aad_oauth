import 'dart:async';
import 'package:aad_oauth/model/token.dart';
import "dart:convert" as Convert;
import 'package:flutter/material.dart';
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
    var json = await _secureStorage.read(key:_identifier);
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
