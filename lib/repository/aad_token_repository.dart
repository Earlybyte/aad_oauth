import 'package:aad_oauth/helper/auth_storage.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/repository/token_repository.dart';
import 'package:aad_oauth/request/authorization_request.dart';
import 'package:aad_oauth/helper/request_token.dart';

class AadTokenRepository extends TokenRepository {
  Token _cachedToken = AuthStorage.emptyToken;
  final AuthStorage _authStorage;
  final AadConfig config;
  final RequestToken _requestToken;
  final String _authUrl;

  AadTokenRepository({required this.config, String tokenIdentifier = 'Token'})
      : _authStorage = AuthStorage(tokenIdentifier: tokenIdentifier),
        _requestToken = RequestToken(config),
        _authUrl =
            '${config.authorizationUrl}?${_mapToQueryParams(AuthorizationRequest(config).parameters)}',
        super(tokenIdentifier: tokenIdentifier);

  @override
  Future<Token> loadTokenFromCache() async {
    if (_cachedToken == AuthStorage.emptyToken) {
      _cachedToken = await _authStorage.loadTokenFromCache();
    }
    return _cachedToken;
  }

  @override
  Future<void> saveTokenToCache(Token token) async {
    _cachedToken = token;
    await _authStorage.saveTokenToCache(_cachedToken);
  }

  @override
  Future<void> clearTokenFromCache() async {
    _cachedToken = AuthStorage.emptyToken;
    await _authStorage.clear();
  }

  @override
  Future<Token> refreshAccessTokenFlow(Token token) async {
    try {
      if (token.hasRefreshToken()) {
        return await _requestToken.requestRefreshToken(token.refreshToken);
      }
    } catch (e) {
      print(e);
    }
    return AuthStorage.emptyToken;
  }

  @override
  Future<Token> requestTokenWithCode(String code) async {
    try {
      final token = await _requestToken.requestToken(code);
      await saveTokenToCache(token);
      return token;
    } catch (e) {
      print(e);
    }
    return AuthStorage.emptyToken;
  }

  static String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add('$key=$value'));
    return queryParams.join('&');
  }

  @override
  String get authorizationUrl => _authUrl;
}
