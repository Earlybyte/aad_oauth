import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aad_oauth/model/token.dart';
import 'dart:convert' show jsonEncode, jsonDecode;

class AuthStorage {
  static const _keyFreshInstall = 'freshInstall';

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

  Future<void> _removeOldTokenOnFirstLogin() async {
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      await clear();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }

  Future<Token> loadTokenFromCache<T extends Token>() async {
    await _removeOldTokenOnFirstLogin();
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
      // scenarios may also cause this); however this should also be caught by
      // _removeOldTokenOnFirstLogin() check above.
      await clear();
      return emptyToken;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic> data) =>
      Token.fromJson(data);

  Future<void> clear() => _secureStorage.delete(key: tokenIdentifier);
}
