import 'package:flutter_test/flutter_test.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

void main() {
  test('adds one to input values', () {
    final Config config = new Config(
      "YOUR TENANT ID",
      "YOUR CLIENT ID",
      "openid profile offline_access");
    final AadOAuth oauth = new AadOAuth(config);

    //TODO testing
    
  });
}
