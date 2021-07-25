import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/model/config.dart';

CoreOAuth getOAuthConfig(Config config) => CoreOAuth.fromConfig(config);
