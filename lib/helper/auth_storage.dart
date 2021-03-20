import 'dart:async';
import 'package:aad_oauth/model/token.dart';
import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static Token emptyToken =
      Token(issueTimeStamp: DateTime.fromMicrosecondsSinceEpoch(0));

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final String tokenIdentifier;

  AuthStorage({this.tokenIdentifier = 'Token'});

  Future<void> saveTokenToCache(Token token) async {
    var data = Token.toJsonMap(token);
    var json = jsonEncode(data);
    await _secureStorage.write(key: tokenIdentifier, value: json);
  }

  Future<Token> loadTokenFromCache<T extends Token>() async {
    var json = await _secureStorage.read(key: tokenIdentifier);
    if (json == null) return emptyToken;
    try {
      var data = jsonDecode(json);
      return _getTokenFromMap<T>(data);
    } catch (exception) {
      print(exception);
      // Token was unable to be loaded from secure storage so we should remove it
      // This might happen if the secure storage was saved on a different device
      // and we're unable to read the data on this device. (uninstall/reinstall
      // scenarios may also cause this)
      await clear();
      return emptyToken;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic> data) =>
      Token.fromJson(data);

  Future<void> clear() => _secureStorage.delete(key: tokenIdentifier);
}
