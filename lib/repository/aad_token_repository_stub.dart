import 'package:aad_oauth/model/token.dart';
import 'package:aad_oauth/repository/token_repository.dart';

class AadTokenRepositoryStub extends TokenRepository {
  AadTokenRepositoryStub() : super(tokenIdentifier: 'StubToken');

  @override
  Future<Token> loadTokenFromCache() async => Token(
      accessToken: 'AccessToken',
      refreshToken: 'RefreshToken',
      issueTimeStamp: DateTime.now().toUtc(),
      expiresIn: 3600);
  @override
  Future<void> saveTokenToCache(Token token) async {}
  @override
  Future<void> clearTokenFromCache({bool? clearCookies}) async {}

  @override
  Future<Token> refreshAccessTokenFlow(Token token) => loadTokenFromCache();

  @override
  Future<Token> requestTokenWithCode(String code) => loadTokenFromCache();

  @override
  String get authorizationUrl => 'about:blank';
}
