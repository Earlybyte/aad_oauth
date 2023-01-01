import 'package:dartz/dartz.dart';

import 'choose_oauth.dart'
    if (dart.library.io) 'mobile_oauth.dart'
    if (dart.library.html) 'web_oauth.dart';
import '../model/config.dart';
import '../model/failure.dart';
import '../model/token.dart';

class CoreOAuth {
  CoreOAuth();

  Future<Either<Failure, Token>> login(
          {bool refreshIfAvailable = false}) async =>
      throw UnsupportedFailure(ErrorType.unsupported, 'Unsupported login');

  Future<void> logout() async =>
      throw UnsupportedFailure(ErrorType.unsupported, 'Unsupported logout');

  Future<String?> getAccessToken() async => throw UnsupportedFailure(
      ErrorType.unsupported, 'Unsupported getAccessToken');

  Future<String?> getIdToken() async => throw UnsupportedFailure(
      ErrorType.unsupported, 'Unsupported getAccessToken');

  factory CoreOAuth.fromConfig(Config config) =>
      config.isStub ? CoreOAuth() : getOAuthConfig(config);
}
