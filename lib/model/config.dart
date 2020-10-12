import 'package:flutter/widgets.dart';

// Parameters according to official Microsoft Documentation: https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
// and B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow

class Config {
  String authorizationUrl;
  String tokenUrl;

  final String tenant; // Azure AD tenant
  final String policy; // userflow for AD B2C
  final String clientId;
  final String responseType;
  final String redirectUri;
  final String scope;
  final String responseMode;
  final String state;
  final String prompt;

  // AD Auth Code Flow
  final String codeChallenge;
  final String codeChallengeMethod;
  String loginHint;
  String domainHint;

  // AD B2C Auth Code Flow
  final String nonce;
  String tokenIdentifier;

  final String clientSecret;
  String codeVerifier;

  final String contentType;

  final String resource;
  final bool isB2C;
  Rect screenSize;
  String userAgent;

  Config(
      {@required this.tenant,
      this.policy,
      @required this.clientId,
      this.responseType = 'code',
      @required this.redirectUri,
      @required this.scope,
      this.responseMode,
      this.state,
      this.prompt,
      this.codeChallenge,
      this.codeChallengeMethod,
      this.nonce = '12345',
      this.tokenIdentifier,
      this.clientSecret,
      this.contentType = 'application/x-www-form-urlencoded',
      this.resource,
      this.isB2C = false,
      this.loginHint,
      this.domainHint,
      this.codeVerifier}) {
    authorizationUrl = isB2C
        ? 'https://$tenant.b2clogin.com/$tenant.onmicrosoft.com/$policy/oauth2/v2.0/authorize'
        : 'https://login.microsoftonline.com/$tenant/oauth2/v2.0/authorize';
    tokenUrl = isB2C
        ? 'https://$tenant.b2clogin.com/$tenant.onmicrosoft.com/$policy/oauth2/v2.0/token'
        : 'https://login.microsoftonline.com/$tenant/oauth2/v2.0/token';
  }
}
