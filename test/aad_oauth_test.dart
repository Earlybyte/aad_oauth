import 'package:flutter_test/flutter_test.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

void main() {
  test('adds one to input values', () {
    final String azureClientId = "";
    final String azureTennant = "";
    final Config config = new Config(
      "https://login.microsoftonline.com/$azureTennant/oauth2/v2.0/authorize",
      "https://login.microsoftonline.com/$azureTennant/oauth2/v2.0/token",
      azureClientId,
      "https://login.live.com/oauth20_desktop.srf",
      "code",
      "openid profile offline_access",
      contentType: "application/x-www-form-urlencoded");
    final AadOAuth oauth = new AadOAuth(config);

    //TODO testing
    
  });
}
