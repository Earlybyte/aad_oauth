import 'package:aad_oauth/model/config.dart';

class AuthorizationRequest {
  final String url;
  final String redirectUrl;
  final Map<String, String> parameters;
  final bool fullScreen;
  final bool clearCookies;

  AuthorizationRequest(Config config,
      {bool fullScreen = true, bool clearCookies = false})
      : url = config.authorizationUrl,
        redirectUrl = config.redirectUri,
        parameters = {
          'client_id': config.clientId,
          'response_type': config.responseType,
          'redirect_uri': config.redirectUri,
          'scope': config.scope,
        },
        fullScreen = fullScreen,
        clearCookies = clearCookies {
    if (config.state != null) {
      parameters.putIfAbsent('state', () => config.state!);
    }
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
