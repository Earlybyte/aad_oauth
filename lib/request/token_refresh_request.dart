import 'package:aad_oauth/model/config.dart';

class TokenRefreshRequestDetails {
  String url;
  Map<String, String> parameters;
  Map<String, String> headers;

  TokenRefreshRequestDetails(AadConfig config, String refreshToken)
      : url = config.tokenUrl,
        parameters = {
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
    _setParametersFromConfig('client_secret', config.clientSecret);
  }

  void _setParametersFromConfig(final String name, final String? value) {
    if (value != null) {
      parameters[name] = value;
    }
  }
}
