import 'package:flutter_test/flutter_test.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

void main() {
  test('Token is not valid before signing in', () {
    final Config config = new Config(
        "YOUR TENANT ID",
        "YOUR CLIENT ID",
        "openid profile offline_access",
        "https://login.live.com/oauth20_desktop.srf");
    final AadOAuth oauth = new AadOAuth(config);

    expect(oauth.tokenIsValid(), false);
    //TODO testing
  });
}
