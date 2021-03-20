import 'package:aad_oauth/model/token.dart';

abstract class TokenRepository {
  final String tokenIdentifier;
  TokenRepository({required this.tokenIdentifier});

  Future<Token> loadTokenFromCache();
  Future<void> saveTokenToCache(Token token);
  Future<void> clearTokenFromCache();

  Future<Token> refreshAccessTokenFlow(Token token);

  Future<Token> requestTokenWithCode(String code);

  String get authorizationUrl => 'about:blank?code=GotCode';
}
