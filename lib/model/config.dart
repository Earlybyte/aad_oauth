import 'package:flutter/widgets.dart';

class Config {
  final String azureTenantId;
  final String azureTenantName;
  final String userFlow;
  String authorizationUrl;
  String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  final String resource;
  final String nonce;
  final bool isB2C;
  Rect screenSize;
  String userAgent;
  String tokenIdentifier;

  Config(
      this.azureTenantId,
      this.clientId,
      this.scope,
      this.redirectUri, {
        this.isB2C = false,
        this.nonce = "12345",
        this.azureTenantName,
        this.userFlow,
        this.clientSecret,
        this.resource,
        this.responseType = "code",
        this.contentType = "application/x-www-form-urlencoded",
        this.screenSize,
        this.userAgent,
        this.tokenIdentifier = "Token",
      }) {
    this.authorizationUrl = isB2C
        ? "https://$azureTenantName.b2clogin.com/$azureTenantName.onmicrosoft.com/oauth2/v2.0/authorize"
        : "https://login.microsoftonline.com/$azureTenantId/oauth2/v2.0/authorize";
    this.tokenUrl = isB2C
        ? "https://$azureTenantName.b2clogin.com/$azureTenantName.onmicrosoft.com/$userFlow/oauth2/v2.0/token"
        : "https://login.microsoftonline.com/$azureTenantId/oauth2/v2.0/token";
  }
}