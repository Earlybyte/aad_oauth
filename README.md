# Azure Active Directory OAuth

[![pub package](https://img.shields.io/pub/v/aad_oauth.svg)](https://pub.dartlang.org/packages/aad_oauth)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub points](https://img.shields.io/pub/points/aad_oauth?logo=dart)](https://pub.dev/packages/aad_oauth/score)
[![Join the chat](https://badges.gitter.im/Earlybyte/aad_oauth.svg)](https://gitter.im/Earlybyte/aad_oauth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:

- [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)
- [Authorization code flow B2C](https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: <https://login.live.com/oauth20_desktop.srf>).

Your minSdkVersion must be >= 20 in `android/app/build.gradle` section `android / defaultConfig` to support webview_flutter. Version 19 may build but will likely fail at runtime.

If your app does not have the `android.permission.INTERNET` permission you must add it to the AndroidManifest
`<uses-permission android:name="android.permission.INTERNET"/>`

Afterwards you must create a navigatorKey and initialize the library as follow:

```dart
  final navigatorKey = GlobalKey<NavigatorState>();

  // ... 

  static final Config config = new Config(
    tenant: "YOUR_TENANT_ID",
    clientId: "YOUR_CLIENT_ID",
    scope: "openid profile offline_access",
    // redirectUri is Optional as a default is calculated based on app type/web location
    redirectUri: "your redirect url available in azure portal",
    navigatorKey: navigatorKey,
    webUseRedirect: true, // default is false - on web only, forces a redirect flow instead of popup auth
    //Optional parameter: Centered CircularProgressIndicator while rendering web page in WebView
    loader: Center(child: CircularProgressIndicator()),
    postLogoutRedirectUri: 'http://your_base_url/logout', //optional
  );

  final AadOAuth oauth = new AadOAuth(config);
```

This allows you to pass in an tenant ID, client ID, scope and redirect url.

The same `navigatorKey` must be provided to the top-level `MaterialApp`.

```dart
  // ...
  // Material App must be built with the same navigatorKey
  // to support navigation to the login route for interactive
  // authentication.
  // ...

    Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      navigatorKey: navigatorKey,
      // ...
    );
  }
```

Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
final result = await oauth.login();
result.fold(
  (failure) => showError(failure.toString()),
  (token) => showMessage('Logged in successfully, your access token: $token'),
);
String accessToken = await oauth.getAccessToken();
```

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

### Web Usage

For web you also have to add some lines to your `index.html` (see the `index.html` in the example applications):
```html
<head>
  <script type="text/javascript" src="https://alcdn.msauth.net/browser/2.13.1/js/msal-browser.min.js"
    integrity="sha384-2Vr9MyareT7qv+wLp1zBt78ZWB4aljfCTMUrml3/cxm0W81ahmDOC6uyNmmn0Vrc"
    crossorigin="anonymous"></script>
  <script src="assets/packages/aad_oauth/assets/msalv2.js"></script>
</head>
```

Note that when using redirect flow on web, the `login()` call will not return if the user has not logged in yet because
the page is redirected and the app is destroyed until login is complete. Your application must take care of calling
`login()` again once reloaded to complete the login process within the flutter application - if login was successful,
this second call will be fast, and will not cause another redirection.

When using redirecting logins with the example application, you will need to click on the login button again following 
a successful login to see the token details. 

### B2C Usage

Setup your B2C directory - [Azure AD B2C Setup](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant/).

Register an App on the previously created B2C directory - [Azure AD B2C App Register](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=applications).

Use native app as plattform type (with callback URL: <https://login.live.com/oauth20_desktop.srf>).

Create your user flows - [Azure AD B2C User Flows](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows)

Add your Azure tenant ID, tenantName, client ID (ID of App), client Secret (Secret of App) and redirectUrl in the main.dart source-code:

```dart
  static final Config configB2Ca = new Config(
    tenant: "YOUR_TENANT_NAME",
    clientId: "YOUR_CLIENT_ID",
    scope: "YOUR_CLIENT_ID offline_access",
    // redirectUri: "https://login.live.com/oauth20_desktop.srf", // Note: this is the default for Mobile
    // clientSecret: "YOUR_CLIENT_SECRET", // Note: do not include secret in publicly available applications
    isB2C: true,
    policy: "YOUR_USER_FLOW___USER_FLOW_A",
    tokenIdentifier: "UNIQUE IDENTIFIER A",
    navigatorKey: navigatorKey,
  );
```

Afterwards you can login and get an access token for accessing other resources. You can also use multiple configs at the same time.

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth: "^0.4.4"
```

## Contribution

Contributions can be submitted as pull requests and are highly welcomed. Changes will be bundled together into a release. You can find the next release date and past releases in the [CHANGELOG file](CHANGELOG.md).
