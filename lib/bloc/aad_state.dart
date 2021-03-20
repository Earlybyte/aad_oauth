part of 'aad_bloc.dart';

@immutable
abstract class AadState extends Equatable {}

// Typical spinner
class AadInitialState extends AadState {
  @override
  List<Object> get props => [AadInitialState];
}

// Will be showing WebView
class AadFullFlowState extends AadState {
  @override
  List<Object> get props => [AadFullFlowState];
}

class AadAuthenticationFailedState extends AadState {
  @override
  List<Object> get props => [AadAuthenticationFailedState];
}

class AadSignedOutState extends AadState {
  @override
  List<Object> get props => [AadSignedOutState];
}

abstract class AadWithTokenState extends AadState {
  final Token token;
  AadWithTokenState({required this.token});

  @override
  List<Object> get props => [AadWithTokenState, token];
}

// Will be silently refreshing - could display indication refresh is in progress
// This is not currently used in the bloc, so can never get to this state
class AadTokenRefreshInProgressState extends AadWithTokenState {
  AadTokenRefreshInProgressState({required Token token}) : super(token: token);

  @override
  List<Object> get props => [AadTokenRefreshInProgressState, token];
}

class AadAuthenticatedState extends AadWithTokenState {
  AadAuthenticatedState({required Token token}) : super(token: token);

  @override
  List<Object> get props => [AadAuthenticatedState, token];
}

class AadInternalErrorState extends AadState {
  final String message;
  AadInternalErrorState(this.message);

  @override
  List<Object?> get props => [AadInternalErrorState, message];
}
