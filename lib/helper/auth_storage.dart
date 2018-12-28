import 'dart:async';
import 'package:aad_oauth/model/token.dart';
import 'package:meta/meta.dart';
import "dart:convert" as Convert;


class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  //We use a basic in memory auth storage for dart.
  Map<String, String> _memoryMap = {};
  final String _identifier = "Token";

  Future<void> saveTokenToCache(Token token) async {
    var data = Token.toJsonMap(token);
    var json = Convert.jsonEncode(data);
    await _write(key: _identifier, value: json);
  }

  Future<T> loadTokenToCache<T extends Token>() async {
    var json = await _read(key: _identifier);
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

  Future<void> _write({@required String key, @required String value}) async =>
      _memoryMap[key] = value;

  Future<String> _read({@required String key}) async =>
      _memoryMap.containsKey(key) ? _memoryMap[key] : null;

  Future clear() async {
    _memoryMap = {};
  }
}
