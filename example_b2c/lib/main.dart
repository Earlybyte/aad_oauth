import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD B2C Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'AAD B2C Home'),
      navigatorKey: navigatorKey,
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
  // Must configure flutter to start the web server for the app on
  // the port listed below. In VSCode, this can be done with
  // the following run settings in launch.json
  // "args": ["-d", "chrome","--web-port", "8483"]

  static final Config configB2Ca = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      redirectUri: kIsWeb
          ? 'http://localhost:8483'
          : 'https://login.live.com/oauth20_desktop.srf',
      clientSecret: 'YOUR_CLIENT_SECRET',
      isB2C: true,
      navigatorKey: navigatorKey,
      policy: 'YOUR_USER_FLOW___USER_FLOW_A',
      tokenIdentifier: 'UNIQUE IDENTIFIER A');

  static final Config configB2Cb = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      navigatorKey: navigatorKey,
      redirectUri: kIsWeb
          ? 'http://localhost:8483'
          : 'https://login.live.com/oauth20_desktop.srf',
      clientSecret: 'YOUR_CLIENT_SECRET',
      isB2C: true,
      policy: 'YOUR_USER_FLOW___USER_FLOW_B',
      tokenIdentifier: 'UNIQUE IDENTIFIER B');

  //You can have as many B2C flows as you want

  final AadOAuth oauthB2Ca = AadOAuth(configB2Ca);
  final AadOAuth oauthB2Cb = AadOAuth(configB2Cb);

  @override
  Widget build(BuildContext context) {
    // adjust window size for browser login

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'AzureAD B2C A',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(oauthB2Ca);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Ca);
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'AzureAD B2C B',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(oauthB2Cb);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Cb);
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void login(AadOAuth oAuth) async {
    try {
      await oAuth.login();
      final accessToken = await oAuth.getAccessToken();
      showMessage('Logged in successfully, your access token: $accessToken');
    } catch (e) {
      showError(e);
    }
  }

  void logout(AadOAuth oAuth) async {
    await oAuth.logout();
    showMessage('Logged out');
  }
}
