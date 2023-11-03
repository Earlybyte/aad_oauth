import 'package:equatable/equatable.dart';

enum ErrorType {
  accessDeniedOrAuthenticationCanceled,
  invalidJson,
  unsupported,
  unexpectedError,
}

abstract class Failure extends Equatable {
  final ErrorType errorType;
  final String message;

  Failure({required this.errorType, required this.message});

  @override
  List<Object> get props => [errorType, message];

  @override
  bool get stringify => true;
}

class RequestFailure extends Failure {
  RequestFailure({required super.errorType, required super.message});
}

class AadOauthFailure extends Failure {
  AadOauthFailure({required super.errorType, required super.message});
}

class UnsupportedFailure extends Failure {
  UnsupportedFailure({required super.errorType, required super.message});
}
