import 'dart:io';

import 'package:aad_oauth/auth_token_provider.dart';
import 'package:aad_oauth/helper/auth_storage.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aad_oauth/azure_login_widget.dart';
import 'package:aad_oauth/bloc/aad_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD OAuth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AAD OAuth Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AuthTokenProvider tokenProvider;
  @override
  void initState() {
    super.initState();

    // Enable hybrid composition - required for keyboard to work on Android 12
    // and requires minSdkVersion of 19
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    // NB: MSALv2 can use same clientId for mobile and SPA web app entry
    // as both use authorization code flow

    // If you configure MSDALv1, you will need to setup a client with
    // implicit flow

    final AzureTenantId = 'YOUR_TENANT_ID';
    final azureClientId = 'YOUR_CLIENT_ID';
    final openIdScope = 'YOUR_SCOPE';

    // tokenProvider =
    //     AuthTokenProvider.config(azureTenantId, azureClientId, 'openid profile offline_access ${openIdScope}');
    // or
    tokenProvider = AuthTokenProvider.fullConfig(
      AadConfig(
        tenant: AzureTenantId,
        clientId: azureClientId,
        scope: 'openid profile offline_access ${openIdScope}',
        // For web: configure redirect URI to match your launch.json here
        // e.g. for below, use "args": ["-d", "chrome","--web-port", "8483"],
        // in vscode, launch.json entry for running the example app
        // Also add http://localhost:8483/ as a Redirect URI in the SPA entry
        // in Azure directory application configuration.
        redirectUri: kIsWeb
            ? 'http://localhost:8483/'
            // Mobile App
            : 'https://login.live.com/oauth20_desktop.srf',
      ),
    );
    tokenProvider.login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Provider<AuthTokenProvider>(
            create: (_) => tokenProvider,
            child: AzureLoginWidget(
              authTokenProvider: tokenProvider,
              whenAuthenticated: _DemoWidget('Authenticated'),
              whenInitial: Center(child: CircularProgressIndicator()),
              whenLoginFailed: _DemoWidget('Login Failed'),
              whenSignedOut: _DemoWidget('Signed Out'),
            )));
  }
}

class _DemoWidget extends StatelessWidget {
  const _DemoWidget(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AadBloc>(context);
    return BlocBuilder(
      builder: (context, state) => ListView(
        children: <Widget>[
          ListTile(title: Text(title)),
          ListTile(
            title: Text(
              'AzureAD OAuth',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              Provider.of<AuthTokenProvider>(context, listen: false).login();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
            onTap: () {
              Provider.of<AuthTokenProvider>(context, listen: false).logout();
            },
          ),
          if (!kIsWeb)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Refresh Token'),
              onTap: () {
                bloc.add(AadTokenRefreshRequestEvent());
              },
            ),
          if (!kIsWeb)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Corrupt Token'),
              onTap: (state is AadWithTokenState)
                  ? () {
                      final token = state.token;
                      final corruptToken = Token(
                        issueTimeStamp: token.issueTimeStamp,
                        accessToken: token.accessToken
                            .substring(0, token.accessToken.length - 10),
                        refreshToken: token.refreshToken
                            .substring(0, token.refreshToken.length - 10),
                        expireTimeStamp:
                            token.expireTimeStamp.millisecondsSinceEpoch,
                        expiresIn: token.expiresIn,
                        idToken: token.idToken,
                        tokenType: token.tokenType,
                      );
                      bloc.add(AadDebugTokenEvent(corruptToken));
                    }
                  : null,
            ),
          if (!kIsWeb)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Forget Access/Refresh Token'),
              onTap: (state is AadWithTokenState)
                  ? () {
                      bloc.add(AadDebugTokenEvent(AuthStorage.emptyToken));
                    }
                  : null,
            ),
          if (!kIsWeb)
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Clear WebView Cookies'),
              onTap: () {
                CookieManager().clearCookies();
              },
            ),
          ListTile(
              title: Text(
            state is AadTokenRefreshInProgressState
                ? 'Refreshing'
                : state is AadWithTokenState
                    ? 'Token: ... ${state.token.accessToken.length > 1150 ? state.token.accessToken.substring(1050, 1150) : state.token.accessToken.length > 80 ? state.token.accessToken.substring(80) : state.token.accessToken} ...'
                    : 'no token',
            textScaleFactor: 0.9,
          )),
        ],
      ),
      bloc: bloc,
    );
  }
}
