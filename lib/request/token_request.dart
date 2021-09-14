import 'package:aad_oauth/model/config.dart';

class TokenRequestDetails {
  final String url;
  final Map<String, String> params;
  final Map<String, String> headers;

  TokenRequestDetails(Config config, String code)
      : url = config.tokenUrl,
        params = {
          'client_id': config.clientId,
          'grant_type': 'authorization_code',
          'scope': config.scope,
          'code': code,
          'redirect_uri': config.redirectUri,
        },
        headers = {
          'Accept': 'application/json',
          'Content-Type': Config.contentType
        } {
    if (config.resource != null) {
      params.putIfAbsent('resource', () => config.resource!);
    }

    if (config.clientSecret != null) {
      params.putIfAbsent('client_secret', () => config.clientSecret!);
    }

    if (config.codeVerifier != null) {
      params.putIfAbsent('code_verifier', () => config.codeVerifier!);
    }
  }
}
