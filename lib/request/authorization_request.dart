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
    if (config.responseMode != null) {
      parameters.putIfAbsent('response_mode', () => config.responseMode!);
    }

    if (config.prompt != null) {
      parameters.putIfAbsent('prompt', () => config.prompt!);
    }

    if (config.loginHint != null) {
      parameters.putIfAbsent('login_hint', () => config.loginHint!);
    }

    if (config.domainHint != null) {
      parameters.putIfAbsent('domain_hint', () => config.domainHint!);
    }

    if (config.codeVerifier != null) {
      parameters.putIfAbsent('code_verifier', () => config.codeVerifier!);
    }

    if (config.codeChallenge != null) {
      parameters.putIfAbsent('code_challenge', () => config.codeChallenge!);
    }

    if (config.codeChallengeMethod != null) {
      parameters.putIfAbsent(
          'code_challenge_method', () => config.codeChallengeMethod!);
    }

    if (config.isB2C) {
      parameters.addAll({
        'nonce': config.nonce,
      });
    }
  }
}
