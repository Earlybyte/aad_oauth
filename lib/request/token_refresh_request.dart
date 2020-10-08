import 'package:aad_oauth/model/config.dart';

class TokenRefreshRequestDetails {
  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRefreshRequestDetails(Config config, String refreshToken) {
    this.url = config.tokenUrl;
    this.params = {
      "client_id": config.clientId,
      "scope": config.scope,
      "redirect_uri": config.redirectUri,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken
    };
    if (config.clientSecret != null)
      params.putIfAbsent("client_secret", () => config.clientSecret);

    this.headers = {
      "Accept": "application/json",
      "Content-Type": config.contentType
    };
  }
}
