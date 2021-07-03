import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/request/request_details.dart';

class AuthorizationRequest extends RequestDetails {
  AuthorizationRequest(
    AadConfig config,
  ) : super(
          uri: Uri.parse(config.authorizationUrl),
          parameters: {
            'client_id': config.clientId,
            'response_type': config.responseType,
            'redirect_uri': config.redirectUri,
            'scope': config.scope,
            'state': config.state,
          },
          headers: {},
        ) {
    addConfigToParameters('response_mode', config.responseMode);
    addConfigToParameters('prompt', config.prompt);
    addConfigToParameters('login_hint', config.loginHint);
    addConfigToParameters('domain_hint', config.domainHint);
    addConfigToParameters('code_verifier', config.codeVerifier);
    addConfigToParameters('code_challenge', config.codeChallenge);
    addConfigToParameters('code_challenge_method', config.codeChallengeMethod);

    if (config.isB2C) {
      parameters.addAll({
        'nonce': config.nonce,
      });
    }
  }
}
