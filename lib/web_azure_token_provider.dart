@JS()
library msauth;

import 'package:aad_oauth/auth_token_provider.dart';
import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository.dart';
import 'dart:async';
import 'package:js/js.dart';

@JS('initialiseMSAL')
external void initialiseMSAL(
    String clientId, String authority, String scope, String redirectUri);

@JS('signout')
external void signout();

@JS('GetBearerToken')
external void _GetBearerToken(void Function(MsalTokenResponse) callback,
    void Function(MsalTokenError) errorCallback);

@JS()
@anonymous
class MsalTokenResponse {
  external factory MsalTokenResponse({accessToken, expiresOn});
  external String get accessToken;
  external int get expiresOn;
}

@JS()
@anonymous
class MsalTokenError {
  external factory MsalTokenError(
      {errorCode, errorMessage, name, subError, message, stack});
  external String get errorCode;
  external String get errorMessage;
  external String get name;
  external String get subError;
  external String get message;
  external String get stack;
}

Future<MsalTokenResponse> GetBearerToken() {
  final completer = Completer<MsalTokenResponse>();
  _GetBearerToken(
      allowInterop(completer.complete), allowInterop(completer.completeError));
  return completer.future;
}

class WebAzureTokenProvider extends AuthTokenProvider {
  WebAzureTokenProvider(
      String AzureTenantId, String clientId, String scope, String redirectUrl)
      : super(
          tokenRepository: AadTokenRepository(
            config: AadConfig(
              tenant: AzureTenantId,
              clientId: clientId,
              scope: 'openid profile offline_access ${scope}',
              redirectUri: redirectUrl,
            ),
          ),
        ) {
    final tr = tokenRepository as AadTokenRepository;
    initialiseMSAL(
        tr.config.clientId,
        'https://login.microsoftonline.com/${tr.config.tenant}',
        tr.config.scope,
        tr.config.redirectUri);
  }

  // TODO: Need to add proper support for other Azure parameters
  // web mode doesn't support b2c flows (yet)
  WebAzureTokenProvider.config(AadConfig config)
      : super(tokenRepository: AadTokenRepository(config: config)) {
    final tr = tokenRepository as AadTokenRepository;
    initialiseMSAL(
        tr.config.clientId,
        'https://login.microsoftonline.com/${tr.config.tenant}',
        tr.config.scope,
        tr.config.redirectUri);
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final accessToken = await GetBearerToken();
      bloc.add(AadMsalTokenAvailableEvent(
          accessToken.accessToken, accessToken.expiresOn));
      return accessToken.accessToken;
    } catch (e) {
      final msalError = e as MsalTokenError;
      print(msalError.message);
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

AuthTokenProvider getAuthTokenProvider(String AzureTenantId, String clientId,
        String openIdScope, String redirectUri) =>
    WebAzureTokenProvider(AzureTenantId, clientId, openIdScope, redirectUri);

AuthTokenProvider getAuthTokenProviderFromConfig(AadConfig config) =>
    WebAzureTokenProvider.config(config);
