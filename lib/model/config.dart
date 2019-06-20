import 'package:flutter/widgets.dart';

class Config {
  final String azureTennantId;
  String authorizationUrl;
  String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  Rect screenSize;

  Config(this.azureTennantId, this.clientId, this.scope, this.redirectUri,
      {this.clientSecret,
      this.responseType = "code",
      this.contentType = "application/x-www-form-urlencoded",
      this.screenSize}) {
    this.authorizationUrl =
        "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/authorize";
    this.tokenUrl =
        "https://login.microsoftonline.com/$azureTennantId/oauth2/v2.0/token";
  }
}
