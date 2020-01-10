import 'package:aad_oauth/model/config.dart';

class TokenRequestDetails {
  String url;
  Map<String, String> params;
  Map<String, String> headers;

  TokenRequestDetails(Config config, String code) {
    this.url = config.tokenUrl;
    this.params = {
      "client_id": config.clientId,
      "code": code,
      "redirect_uri": config.redirectUri,
      "grant_type": "authorization_code",
      "resource": config.resource
    };

    if (config.resource != null)
      params.putIfAbsent("resource", () => config.resource);

    if (config.clientSecret != null)
      params.putIfAbsent("client_secret", () => config.clientSecret);

    this.headers = {
      "Accept": "application/json",
      "Content-Type": config.contentType
    };
  }
}
