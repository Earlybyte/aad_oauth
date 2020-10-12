import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
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
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Config configB2Ca = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      redirectUri: 'https://login.live.com/oauth20_desktop.srf',
      clientSecret: 'YOUR_CLIENT_SECRET',
      isB2C: true,
      policy: 'YOUR_USER_FLOW___USER_FLOW_A',
      tokenIdentifier: 'UNIQUE IDENTIFIER A');

  static final Config configB2Cb = Config(
      tenant: 'YOUR_TENANT_NAME',
      clientId: 'YOUR_CLIENT_ID',
      scope: 'YOUR_CLIENT_ID offline_access',
      redirectUri: 'https://login.live.com/oauth20_desktop.srf',
      clientSecret: 'YOUR_CLIENT_SECRET',
      isB2C: true,
      policy: 'YOUR_USER_FLOW___USER_FLOW_B',
      tokenIdentifier: 'UNIQUE IDENTIFIER B');

  //You can have as many B2C flows as you want

  final AadOAuth oauthB2Ca = AadOAuth(configB2Ca);
  final AadOAuth oauthB2Cb = AadOAuth(configB2Cb);

  Widget build(BuildContext context) {
    // adjust window size for browser login
    var screenSize = MediaQuery.of(context).size;
    var rectSize =
        Rect.fromLTWH(0.0, 25.0, screenSize.width, screenSize.height - 25);
    oauthB2Ca.setWebViewScreenSize(rectSize);

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
      FlatButton(
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
      String accessToken = await oAuth.getAccessToken();
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
