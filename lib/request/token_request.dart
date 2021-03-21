import 'package:aad_oauth/model/config.dart';

class TokenRequestDetails {
  String url;
  Map<String, String> parameters;
  Map<String, String> headers;

  TokenRequestDetails(AadConfig config, String code)
      : url = config.tokenUrl,
        parameters = {
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
    _setParametersFromConfig('resource', config.resource);
    _setParametersFromConfig('client_secret', config.clientSecret);
    _setParametersFromConfig('code_verifier', config.codeVerifier);
  }

  void _setParametersFromConfig(final String name, final String? value) {
    if (value != null) {
      parameters[name] = value;
    }
  }
}
