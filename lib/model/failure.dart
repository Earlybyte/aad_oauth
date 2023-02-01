import 'package:equatable/equatable.dart';

enum ErrorType {
  AccessDeniedOrAuthenticationCanceled,
  InvalidJson,
  Unsupported,
  UnexpectedError,
}

abstract class Failure extends Equatable {
  final ErrorType errorType;
  final String message;

  Failure(this.errorType, this.message);

  @override
  List<Object> get props => [errorType, message];

  @override
  bool get stringify => true;
}

class RequestFailure extends Failure {
  RequestFailure(errorType, message) : super(errorType, message);
}

class AadOauthFailure extends Failure {
  AadOauthFailure(errorType, message) : super(errorType, message);
}

class UnsupportedFailure extends Failure {
  UnsupportedFailure(errorType, message) : super(errorType, message);
}
