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
    final azureTenantId = 'AZURE_TENANT_ID';
    final openIdScope = 'additional_scope';
    // NB: clientId for mobile web can be different to mobile app
    final azureClientId = kIsWeb ? 'WEB_AZURE_CLIENT' : 'MOBILE_AZURE_CLIENT';

    // tokenProvider =
    //     AuthTokenProvider.config(azureTenantId, azureClientId, openIdScope);
    // or
    tokenProvider = AuthTokenProvider.fullConfig(
      AadConfig(
        tenant: azureTenantId,
        clientId: azureClientId,
        scope: 'openid profile offline_access ${openIdScope}',
        redirectUri: 'https://login.live.com/oauth20_desktop.srf',
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
        body: AzureLoginWidget(
          authTokenProvider: tokenProvider,
          whenAuthenticated: _DemoWidget('Authenticated'),
          whenInitial: Center(child: CircularProgressIndicator()),
          whenLoginFailed: _DemoWidget('Login Failed'),
          whenSignedOut: _DemoWidget('Signed Out'),
        ));
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
              bloc.add(AadLoginRequestEvent());
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
            onTap: () {
              bloc.add(AadLogoutRequestEvent());
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Refresh Token'),
            onTap: () {
              bloc.add(AadTokenRefreshRequestEvent());
            },
          ),
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
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Forget Access/Refresh Token'),
            onTap: (state is AadWithTokenState)
                ? () {
                    bloc.add(AadDebugTokenEvent(AuthStorage.emptyToken));
                  }
                : null,
          ),
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
