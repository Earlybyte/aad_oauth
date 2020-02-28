import 'package:flutter/widgets.dart';

class Config {
  final String azureTennantId;
  final String azureTennantName;
  final String userJourney;
  String authorizationUrl;
  String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  final String resource;
  final bool isB2C;
  Rect screenSize;
  String userAgent;

  Config(this.azureTennantId, this.clientId, this.scope, this.redirectUri,
      {
        this.isB2C = false,
        this.azureTennantName,
        this.userJourney,
        this.clientSecret,
        this.resource,
        this.responseType = "code",
        this.contentType = "application/x-www-form-urlencoded",
        this.screenSize,
        this.userAgent,
      }) {
    this.authorizationUrl = isB2C ? "https://$azureTennantName.b2clogin.com/$azureTennantName.onmicrosoft.com/oauth2/v2.0/authorize" :
    "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/authorize";
    this.tokenUrl = isB2C ? "https://$azureTennantName.b2clogin.com/$azureTennantName.onmicrosoft.com/$userJourney/oauth2/v2.0/token" :
    "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/token";
  }
}
