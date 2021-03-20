import 'package:aad_oauth/model/config.dart';

class TokenRequestDetails {
  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRequestDetails(AadConfig config, String code)
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
          'Content-Type': AadConfig.contentType
        } {
    if (config.resource != null) {
      params['resource'] = config.resource!;
    }

    if (config.clientSecret != null) {
      params['client_secret'] = config.clientSecret!;
    }

    if (config.codeVerifier != null) {
      params['code_verifier'] = config.codeVerifier!;
    }
  }
}
