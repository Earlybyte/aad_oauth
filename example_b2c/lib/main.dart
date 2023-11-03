import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
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
  MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final Config configB2Ca = Config(
    tenant: 'YOUR_TENANT_NAME',
    clientId: 'YOUR_CLIENT_ID',
    scope: 'YOUR_CLIENT_ID offline_access',
    clientSecret: 'YOUR_CLIENT_SECRET',
    isB2C: true,
    navigatorKey: navigatorKey,
    policy: 'YOUR_USER_FLOW___USER_FLOW_A',
    tokenIdentifier: 'UNIQUE IDENTIFIER A',
    loader: SizedBox(),
    appBar: AppBar(
      title: Text('AAD OAuth Demo'),
    ),
  );

  static final Config configB2Cb = Config(
    tenant: 'YOUR_TENANT_NAME',
    clientId: 'YOUR_CLIENT_ID',
    scope: 'YOUR_CLIENT_ID offline_access',
    navigatorKey: navigatorKey,
    clientSecret: 'YOUR_CLIENT_SECRET',
    isB2C: true,
    policy: 'YOUR_USER_FLOW___USER_FLOW_B',
    tokenIdentifier: 'UNIQUE IDENTIFIER B',
    loader: SizedBox(),
    appBar: AppBar(
      title: Text('AAD OAuth Demo'),
    ),
  );

  static final Config configB2Cc = Config(
    tenant: 'YOUR_TENANT_NAME',
    clientId: 'YOUR_CLIENT_ID',
    scope: 'YOUR_CLIENT_ID offline_access',
    navigatorKey: navigatorKey,
    redirectUri: 'YOUR_REDIRECT_URL',
    isB2C: true,
    policy: 'YOUR_CUSTOM_POLICY',
    tokenIdentifier: 'UNIQUE IDENTIFIER C',
    customParameters: {'YOUR_CUSTOM_PARAMETER': 'CUSTOM_VALUE'},
    loader: SizedBox(),
    appBar: AppBar(
      title: Text('AAD OAuth Demo'),
    ),
  );

  //You can have as many B2C flows as you want

  final AadOAuth oauthB2Ca = AadOAuth(configB2Ca);
  final AadOAuth oauthB2Cb = AadOAuth(configB2Cb);
  final AadOAuth oauthB2Cc = AadOAuth(configB2Cc);

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
              style: Theme.of(context).textTheme.headlineSmall,
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
            leading: Icon(Icons.data_array),
            title: Text('HasCachedAccountInformation'),
            onTap: () => hasCachedAccountInformation(oauthB2Ca),
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
              style: Theme.of(context).textTheme.headlineSmall,
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
          Divider(),
          ListTile(
            title: Text(
              'AzureAD B2C C',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login(oauthB2Cc);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              logout(oauthB2Cc);
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
    final result = await oAuth.login();
    result.fold(
      (l) => showError(l.toString()),
      (r) => showMessage('Logged in successfully, your access token: $r'),
    );

    var accessToken = await oAuth.getAccessToken();
    if (accessToken != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(accessToken)));
    }
  }

  void hasCachedAccountInformation(AadOAuth oAuth) async {
    var hasCachedAccountInformation = await oAuth.hasCachedAccountInformation;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('HasCachedAccountInformation: $hasCachedAccountInformation'),
      ),
    );
  }

  void logout(AadOAuth oAuth) async {
    await oAuth.logout();
    showMessage('Logged out');
  }
}
