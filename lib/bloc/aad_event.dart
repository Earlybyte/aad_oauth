part of 'aad_bloc.dart';

@immutable
abstract class AadEvent extends Equatable {
  @override
  List<Object> get props => [runtimeType];
}

class AadTokenRefreshRequestEvent extends AadEvent {
  AadTokenRefreshRequestEvent();
}

class AadSignInErrorEvent extends AadEvent {
  final String description;

  AadSignInErrorEvent(this.description);

  @override
  List<Object> get props => [runtimeType, description];
}

class AadLogoutRequestEvent extends AadEvent {}

class AadLoginRequestEvent extends AadEvent {}

class AadFullFlowUrlLoadedEvent extends AadEvent {
  final String url;

  AadFullFlowUrlLoadedEvent(this.url);
  @override
  List<Object> get props => [runtimeType, url];
}

class AadDebugTokenEvent extends AadEvent {
  AadDebugTokenEvent(this.debugToken);
  final Token debugToken;
  @override
  List<Object> get props => [runtimeType, debugToken];
}
