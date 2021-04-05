# Azure Active Directory OAuth

[![pub package](https://img.shields.io/pub/v/aad_oauth.svg)](https://pub.dartlang.org/packages/aad_oauth)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![pub points](https://badges.bar/aad_oauth/pub%20points)](https://pub.dev/packages/aad_oauth/score) 
[![Join the chat at https://gitter.im/Earlybyte/aad_oauth](https://badges.gitter.im/Earlybyte/aad_oauth.svg)](https://gitter.im/Earlybyte/aad_oauth?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:

- [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)
- [Authorization code flow B2C](https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow)

Note that B2C flow hasn't been tested and will very likely require effort to get working.

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Afterwards you have to initialize the library as follow:

```dart
    // tokenProvider =
    //     AuthTokenProvider.config('YOUR_TENANT_ID', 'YOUR_CLIENT_ID', 'additional_scope');
    // or the long-hand equivalent
    tokenProvider = AuthTokenProvider.fullConfig(
      AadConfig(
        tenant: 'YOUR_TENANT_ID',
        clientId: 'YOUR_CLIENT_ID'
        scope: 'openid profile offline_access additional_scope',
        redirectUri: 'https://login.live.com/oauth20_desktop.srf',
      ),
    );
    tokenProvider.login();

```

This allows you to pass in an tenant ID, client ID, scope and redirect url.

For mobile use, you must embed an AzureLoginWidget in the build() method.
```dart
 return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: AzureLoginWidget(
          authTokenProvider: tokenProvider,
          whenAuthenticated: Text('Signed In'),
          whenInitial: Center(child: CircularProgressIndicator()),
          whenLoginFailed: Text('Login Failed'),
          whenSignedOut: Text('Signed Out'),
        ));
```
Under mobile, this widget will always pass-through to the appropriate widget tree depending
on the authentication state. If only whenAuthenticated is provided, then it always passes
through to whenAuthenticated, regardless of state. 

To use `SurfaceAndroidWebView` for hybrid composition, you must arrange for this yourself. This
is because to do so you must bump your `minSdkVersion` from `18` to at least `19` in `build.gradle` of
your application. From the `flutter_webview` documentation, the following snippet will enable
hybrid composition.

```dart
    // Enable hybrid composition on Android
    if (!kIsWeb && Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }
```

When a full-flow authentication is required, the widget will pass through to a webview
initialized with the tenant signin location derived from the configuration.

Under web, the AzureLoginWidget always passes through to whenAuthenticated as state tracking
is handled directly by underlying javascript library from Microsoft. Under web, when a full
interactive auth flow is required, the flutter web app will be redirected to the azure login
page, and will return to the original app once a token is available.

Then once you have a tokenProvider instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
await tokenProvider.login();
String accessToken = await tokenProvider.getAccessToken();
```



You can also call `getAccessToken()` directly. It will automatically login and retrieve an access token.

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

On web platform,
* tokens are stored by the underlying msauth.js library in the browser localStorage.
* logout does nothing to forget tokens in this release.

## B2C Usage

Setup your B2C directory - [Azure AD B2C Setup](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant/).
<br></br>Register an App on the previously created B2C directory - [Azure AD B2C App Register](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=applications).
<br></br>Use native app as plattform type (with callback URL: https://login.live.com/oauth20_desktop.srf).
<br></br>Create your user flows - [Azure AD B2C User Flows](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows)

Add your Azure tenant ID, tenantName, client ID (ID of App), client Secret (Secret of App) and redirectUrl in the main.dart source-code:

```dart
  static final Config configB2Ca = new AadConfig(
      tenant: "YOUR_TENANT_NAME",
      clientId: "YOUR_CLIENT_ID",
      scope: "YOUR_CLIENT_ID offline_access",
      redirectUri: "https://login.live.com/oauth20_desktop.srf",
      clientSecret: "YOUR_CLIENT_SECRET",
      isB2C: true,
      policy: "YOUR_USER_FLOW___USER_FLOW_A",
      tokenIdentifier: "UNIQUE IDENTIFIER A");
```

## Flutter Web Usage
For Flutter Web, add the MSAL js to your index.html in the `<head>` section:
```html
  <script type="text/javascript" src="https://alcdn.msftauth.net/lib/1.4.8/js/msal.js"
    integrity="sha384-rLIIWk6gwb6EYl6uqmTG4fjUDijpqsPlUxNvjdOcqt/OitOkxXKAJf6HhNEjRDBD"
    crossorigin="anonymous"></script>
  <script src="assets/packages/aad_oauth/assets/msal_auth.js"></script>
```

Afterwards you can login and get an access token for accessing other resources. You can also use multiple configs at the same time.

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth: "^0.3.0"
```

## Contribution

Contributions can be submitted as pull requests and are highly welcomed. Changes will be bundled together into a release. You can find the next release date and past releases in the [CHANGELOG file](CHANGELOG.md).
