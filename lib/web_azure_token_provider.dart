@JS()
library msauth;

import 'package:aad_oauth/auth_token_provider.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository_stub.dart';
import 'dart:async';
import 'package:js/js.dart';

@JS('initialiseMSAL')
external void initialiseMSAL(String clientId, String authority, String scope);

@JS('GetBearerToken')
external void _GetBearerToken(
    void Function(String) callback, void Function(String) errorCallback);

Future<String> GetBearerToken() {
  final completer = Completer<String>();
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
        super(tokenRepository: AadTokenRepositoryStub()) {
    initialiseMSAL(clientId, authority, scope);
  }

  // TODO: Need to add proper support for other Azure parameters
  WebAzureTokenProvider.config(AadConfig config)
      : authority = 'https://login.microsoftonline.com/${config.tenant}',
        AzureTenantId = config.tenant,
        clientId = config.clientId,
        scope = config.scope,
        super(tokenRepository: AadTokenRepositoryStub()) {
    initialiseMSAL(clientId, authority, scope);
  }
  @override
  Future<String?> getAccessToken() async {
    try {
      return await GetBearerToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> login() async {
    await getAccessToken();
  }

  @override
  Future<void> logout() async {
    // ignore logout on the web... for now
    return;
  }
}

AuthTokenProvider getAuthTokenProvider(
        String AzureTenantId, String clientId, String openIdScope) =>
    WebAzureTokenProvider(AzureTenantId, clientId, openIdScope);
