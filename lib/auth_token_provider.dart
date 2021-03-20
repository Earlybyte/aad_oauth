import 'package:aad_oauth/repository/token_repository.dart';
import 'package:aad_oauth/auth_token_provider_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:aad_oauth/mobile_azure_token_provider.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:aad_oauth/web_azure_token_provider.dart';

import 'model/config.dart';

class AuthTokenProvider {
  final TokenRepository tokenRepository;

  Future<String?> getAccessToken() async {
    return Future<String>.value('stub');
  }

  Future<void> login() async {
    return Future.delayed(Duration(milliseconds: 0));
  }

  Future<void> logout() async {
    return Future.delayed(Duration(milliseconds: 0));
  }

  factory AuthTokenProvider.fullConfig(AadConfig config) =>
      getAuthTokenProviderFromConfig(config);

  factory AuthTokenProvider.config(
          String AzureTenantId, String clientId, String openIdScope) =>
      getAuthTokenProvider(AzureTenantId, clientId, openIdScope);
  AuthTokenProvider({required this.tokenRepository});
}
