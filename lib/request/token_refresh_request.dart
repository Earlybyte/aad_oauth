import 'package:aad_oauth/model/config.dart';

class TokenRefreshRequestDetails {
  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRefreshRequestDetails(AadConfig config, String refreshToken)
      : url = config.tokenUrl,
        params = {
          'client_id': config.clientId,
          'scope': config.scope,
          'redirect_uri': config.redirectUri,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken
        },
        headers = {
          'Accept': 'application/json',
          'Content-Type': AadConfig.contentType
        } {
    if (config.clientSecret != null) {
      params['client_secret'] = config.clientSecret!;
    }
  }
}
