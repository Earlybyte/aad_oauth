import 'package:flutter/widgets.dart';

class Config {
  final String authorizationUrl;
  final String tokenUrl;
  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final String responseType;
  final String contentType;
  final String scope;
  Size screenSize;

  Config(this.authorizationUrl, this.tokenUrl, this.clientId, this.redirectUri, this.responseType, this.scope,
      {this.clientSecret, this.contentType = "application/json", this.screenSize});

}