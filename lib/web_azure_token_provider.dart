@JS()
library msauth;

import 'package:aad_oauth/auth_token_provider.dart';
import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository.dart';
import 'dart:async';
import 'package:js/js.dart';

@JS('initialiseMSAL')
external void initialiseMSAL(String clientId, String authority, String scope);

@JS('signout')
external void signout();

@JS('GetBearerToken')
external void _GetBearerToken(void Function(MsalTokenResponse) callback,
    void Function(String) errorCallback);

@JS()
@anonymous
class MsalTokenResponse {
  external factory MsalTokenResponse({accessToken, expiresOn});
  external String get accessToken;
  external int get expiresOn;
}

Future<MsalTokenResponse> GetBearerToken() {
  final completer = Completer<MsalTokenResponse>();
  _GetBearerToken(
      allowInterop(completer.complete), allowInterop(completer.completeError));
  return completer.future;
}

class WebAzureTokenProvider extends AuthTokenProvider {
  final String clientId;
  final String AzureTenantId;
  final String scope;
  final String authority;

  WebAzureTokenProvider(this.AzureTenantId, this.clientId, this.scope)
      : authority = 'https://login.microsoftonline.com/${AzureTenantId}',
        super(
          tokenRepository: AadTokenRepository(
            config: AadConfig(
              redirectUri: 'about:blank',
              clientId: clientId,
              tenant: AzureTenantId,
              scope: scope,
            ),
          ),
        ) {
    initialiseMSAL(clientId, authority, scope);
  }

  // TODO: Need to add proper support for other Azure parameters
  // web mode doesn't support b2c flows
  WebAzureTokenProvider.config(AadConfig config)
      : authority = 'https://login.microsoftonline.com/${config.tenant}',
        AzureTenantId = config.tenant,
        clientId = config.clientId,
        scope = config.scope,
        super(tokenRepository: AadTokenRepository(config: config)) {
    initialiseMSAL(clientId, authority, scope);
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final accessToken = await GetBearerToken();
      bloc.add(AadMsalTokenAvailableEvent(
          accessToken.accessToken, accessToken.expiresOn));
      return accessToken.accessToken;
    } catch (e) {
      bloc.add(AadNoTokenAvailableEvent());
      return null;
    }
  }

  @override
  Future<void> login() async {
    await getAccessToken();
  }

  @override
  Future<void> logout() async {
    signout();
    bloc.add(AadNoTokenAvailableEvent());
    return;
  }
}

AuthTokenProvider getAuthTokenProvider(
        String AzureTenantId, String clientId, String openIdScope) =>
    WebAzureTokenProvider(AzureTenantId, clientId, openIdScope);

AuthTokenProvider getAuthTokenProviderFromConfig(AadConfig config) =>
    WebAzureTokenProvider.config(config);
