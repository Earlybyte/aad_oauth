import 'package:aad_oauth/model/config.dart';

class AuthorizationRequest {
  String url;
  String redirectUrl;
  Map<String, String> parameters;

  AuthorizationRequest(
    AadConfig config,
  )   : url = config.authorizationUrl,
        redirectUrl = config.redirectUri,
        parameters = {
          'client_id': config.clientId,
          'response_type': config.responseType,
          'redirect_uri': config.redirectUri,
          'scope': config.scope,
          'state': config.state,
        } {
    _addConfigToParameters('response_mode', config.responseMode);
    _addConfigToParameters('prompt', config.prompt);
    _addConfigToParameters('login_hint', config.loginHint);
    _addConfigToParameters('domain_hint', config.domainHint);
    _addConfigToParameters('code_verifier', config.codeVerifier);
    _addConfigToParameters('code_challenge', config.codeChallenge);
    _addConfigToParameters('code_challenge_method', config.codeChallengeMethod);

    if (config.isB2C) {
      parameters.addAll({
        'nonce': config.nonce,
      });
    }
  }

  void _addConfigToParameters(String name, String? value) {
    if (value != null) {
      parameters.putIfAbsent(name, () => value);
    }
  }
}
