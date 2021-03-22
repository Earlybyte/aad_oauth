import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:aad_oauth/repository/token_repository.dart';
import 'package:aad_oauth/auth_token_provider_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:aad_oauth/mobile_azure_token_provider.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:aad_oauth/web_azure_token_provider.dart';

import 'model/config.dart';

class AuthTokenProvider {
  final TokenRepository tokenRepository;
  final AadBloc bloc;

  AuthTokenProvider({required this.tokenRepository})
      : bloc = AadBloc(tokenRepository: tokenRepository);

  Future<void> login() async {
    bloc.add(AadLoginRequestEvent());
  }

  Future<void> logout() async {
    bloc.add(AadLogoutRequestEvent());
    //return oauth.logout();
  }

  Future<String?> getAccessToken() async {
    final state = bloc.state;
    if (state is AadWithTokenState) {
      final token = state.token;
      if (token.hasValidAccessToken()) {
        //print("Token was good");
        return token.accessToken;
      } else {
        //print("Token was not valid...");
      }
    }

    await login();
    await for (final aadState in bloc.stream) {
      //print("Processed ${aadState.runtimeType.toString()} awaiting token");
      if (aadState is AadWithTokenState) {
        final token = aadState.token;
        if (token.hasValidAccessToken()) {
          //print("Token acquired: ${token.accessToken}");
          return token.accessToken;
        } else {
          //print("token has expired - attempting to refresh");
          await login();
        }
      } else if (aadState is AadAuthenticationFailedState) {
        return null;
      } else if (aadState is AadSignedOutState) {
        return null;
      }
    }
    return null;
  }

  factory AuthTokenProvider.fullConfig(AadConfig config) =>
      getAuthTokenProviderFromConfig(config);

  factory AuthTokenProvider.config(
          String AzureTenantId, String clientId, String openIdScope) =>
      getAuthTokenProvider(AzureTenantId, clientId, openIdScope);
}
