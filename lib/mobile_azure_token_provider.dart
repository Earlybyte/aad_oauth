import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository.dart';
import 'package:aad_oauth/auth_token_provider.dart';

class MobileAzureTokenProvider extends AuthTokenProvider {
  late final AadBloc bloc;

  MobileAzureTokenProvider(
      String AzureTenantId, String clientId, String openIdScope)
      : super(
          tokenRepository: AadTokenRepository(
            config: AadConfig(
              tenant: AzureTenantId,
              clientId: clientId,
              scope: 'openid profile offline_access ${openIdScope}',
              redirectUri: 'https://login.live.com/oauth20_desktop.srf',
            ),
          ),
        ) {
    bloc = AadBloc(
      tokenRepository: tokenRepository,
    );
  }
  MobileAzureTokenProvider.config(AadConfig config)
      : super(
          tokenRepository: AadTokenRepository(config: config),
        ) {
    bloc = AadBloc(
      tokenRepository: tokenRepository,
    );
  }

  @override
  Future<void> login() async {
    bloc.add(AadLoginRequestEvent());
  }

  @override
  Future<void> logout() async {
    bloc.add(AadLogoutRequestEvent());
    //return oauth.logout();
  }

  @override
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
}

AuthTokenProvider getAuthTokenProviderFromConfig(AadConfig config) =>
    MobileAzureTokenProvider.config(config);

AuthTokenProvider getAuthTokenProvider(
        String AzureTenantId, String clientId, String openIdScope) =>
    MobileAzureTokenProvider(AzureTenantId, clientId, openIdScope);
