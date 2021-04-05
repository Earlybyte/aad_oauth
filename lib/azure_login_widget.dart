import 'package:aad_oauth/auth_token_provider.dart';
import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AzureLoginWidget extends StatelessWidget {
  final AuthTokenProvider authTokenProvider;
  final Widget whenAuthenticated;
  final Widget whenSignedOut;
  final Widget whenInitial;
  final Widget whenLoginFailed;
  AzureLoginWidget({
    required this.whenAuthenticated,
    required this.authTokenProvider,
    Widget? whenInitial,
    Widget? whenSignedOut,
    Widget? whenLoginFailed,
  })  : whenInitial = whenInitial ?? whenAuthenticated,
        whenSignedOut = whenSignedOut ?? whenAuthenticated,
        whenLoginFailed = whenLoginFailed ?? whenAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authTokenProvider.bloc,
      child: _AzureLoginSubTree(
        whenAuthenticated: whenAuthenticated,
        whenSignedOut: whenSignedOut,
        whenInitial: whenInitial,
        whenLoginFailed: whenLoginFailed,
      ),
    );
  }
}

class _AzureLoginSubTree extends StatelessWidget {
  final Widget whenAuthenticated;
  final Widget whenSignedOut;
  final Widget whenInitial;
  final Widget whenLoginFailed;

  _AzureLoginSubTree(
      {required this.whenAuthenticated,
      required this.whenInitial,
      required this.whenSignedOut,
      required this.whenLoginFailed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadBloc, AadState>(builder: (context, state) {
      if (state is AadInitialState) {
        return whenInitial;
      }
      if (state is AadFullFlowState) {
        return _FullLoginFlowWidget();
      }
      if (state is AadAuthenticationFailedState) {
        return whenLoginFailed;
      }
      if (state is AadSignedOutState) {
        return whenSignedOut;
      }
      if (state is AadWithTokenState) {
        return whenAuthenticated;
      }
      if (state is AadInternalErrorState) {
        return Center(child: Text(state.message));
      }
      return Center(
          child:
              Text('Unknown Azure AD State encountered: ${state.runtimeType}'));
    });
  }
}

class _FullLoginFlowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AadBloc, AadState>(
      builder: (context, state) {
        final bloc = BlocProvider.of<AadBloc>(context);
        return WebView(
          initialUrl: bloc.tokenRepository.authorizationUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onPageStarted: (String url) {
            bloc.add(AadFullFlowUrlLoadedEvent(url));
          },
          onWebResourceError: (WebResourceError wre) {
            bloc.add(AadSignInErrorEvent(wre.description));
          },
        );
      },
    );
  }
}
