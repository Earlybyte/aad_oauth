/// Microsoft identity platform authentication library.
@JS()
library msauth;

import 'dart:js_interop';

/// Interop with JS, we need to convert Config to a JS object or it comes
/// through as empty when passed to JS.
///
/// Parameters according to official Microsoft Documentation:
/// - Azure AD https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
/// - Azure AD B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow
///
/// DartDocs of parameters are mostly from those pages.
@JS()
@staticInterop
class MsalConfig {}

@JS('eval')
external JSAny _jsEval(String code);

/// Factory to create MsalConfig instances
class MsalConfigFactory {
  /// Create a new MsalConfig object with the given parameters
  static MsalConfig construct({
    String? tenant,
    String? policy,
    String? clientId,
    String? responseType,
    String? redirectUri,
    String? scope,
    String? responseMode,
    String? state,
    String? prompt,
    String? codeChallenge,
    String? codeChallengeMethod,
    String? nonce,
    String? tokenIdentifier,
    String? clientSecret,
    String? resource,
    bool? isB2C,
    String? customAuthorizationUrl,
    String? customTokenUrl,
    String? loginHint,
    String? domainHint,
    String? codeVerifier,
    String? authorizationUrl,
    String? tokenUrl,
    String? cacheLocation,
    String? customParameters,
    String? postLogoutRedirectUri,
  }) {
    final configScript = '''
      (function() {
        var config = {};
        ${tenant != null ? 'config.tenant = "${_escapeJS(tenant)}";' : ''}
        ${policy != null ? 'config.policy = "${_escapeJS(policy)}";' : ''}
        ${clientId != null ? 'config.clientId = "${_escapeJS(clientId)}";' : ''}
        ${responseType != null ? 'config.responseType = "${_escapeJS(responseType)}";' : ''}
        ${redirectUri != null ? 'config.redirectUri = "${_escapeJS(redirectUri)}";' : ''}
        ${scope != null ? 'config.scope = "${_escapeJS(scope)}";' : ''}
        ${responseMode != null ? 'config.responseMode = "${_escapeJS(responseMode)}";' : ''}
        ${state != null ? 'config.state = "${_escapeJS(state)}";' : ''}
        ${prompt != null ? 'config.prompt = "${_escapeJS(prompt)}";' : ''}
        ${codeChallenge != null ? 'config.codeChallenge = "${_escapeJS(codeChallenge)}";' : ''}
        ${codeChallengeMethod != null ? 'config.codeChallengeMethod = "${_escapeJS(codeChallengeMethod)}";' : ''}
        ${nonce != null ? 'config.nonce = "${_escapeJS(nonce)}";' : ''}
        ${tokenIdentifier != null ? 'config.tokenIdentifier = "${_escapeJS(tokenIdentifier)}";' : ''}
        ${clientSecret != null ? 'config.clientSecret = "${_escapeJS(clientSecret)}";' : ''}
        ${resource != null ? 'config.resource = "${_escapeJS(resource)}";' : ''}
        ${isB2C != null ? 'config.isB2C = $isB2C;' : ''}
        ${customAuthorizationUrl != null ? 'config.customAuthorizationUrl = "${_escapeJS(customAuthorizationUrl)}";' : ''}
        ${customTokenUrl != null ? 'config.customTokenUrl = "${_escapeJS(customTokenUrl)}";' : ''}
        ${loginHint != null ? 'config.loginHint = "${_escapeJS(loginHint)}";' : ''}
        ${domainHint != null ? 'config.domainHint = "${_escapeJS(domainHint)}";' : ''}
        ${codeVerifier != null ? 'config.codeVerifier = "${_escapeJS(codeVerifier)}";' : ''}
        ${authorizationUrl != null ? 'config.authorizationUrl = "${_escapeJS(authorizationUrl)}";' : ''}
        ${tokenUrl != null ? 'config.tokenUrl = "${_escapeJS(tokenUrl)}";' : ''}
        ${cacheLocation != null ? 'config.cacheLocation = "${_escapeJS(cacheLocation)}";' : ''}
        ${customParameters != null ? 'config.customParameters = "${_escapeJS(customParameters)}";' : ''}
        ${postLogoutRedirectUri != null ? 'config.postLogoutRedirectUri = "${_escapeJS(postLogoutRedirectUri)}";' : ''}
        return config;
      })()
    ''';

    return _jsEval(configScript) as MsalConfig;
  }

  static String _escapeJS(String value) {
    return value.replaceAll('"', '\\"').replaceAll('\n', '\\n');
  }
}
