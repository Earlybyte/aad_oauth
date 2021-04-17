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

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/).
Use native app as platform type (with callback URL: https://login.live.com/oauth20_desktop.srf). To support flutter web, add
an SPA type Redirect URI pointing to the root of the flutter application (e.g. 'http://localhost:8483/' when running on localhost
port 8483). You may find it useful to "lock" flutter web to a single local port when debugging by adding launch.json with args (e.g.
`"args": ["-d", "chrome","--web-port", "8483"],`) since the redirect URI must be known by Azure ahead of time.

Afterwards you have to initialize the library as follow:

```dart
     tokenProvider =
         AuthTokenProvider.config('YOUR_TENANT_ID', 'YOUR_CLIENT_ID', 'additional_scope', kIsWeb
            // Web app - use the root of your web app here - localhost for local testing
            ? 'http://localhost:8483/'
            // Mobile App
           : 'https://login.live.com/oauth20_desktop.srf',);
```

or the long-hand equivalent

```dart
    tokenProvider = AuthTokenProvider.fullConfig(
      AadConfig(
        tenant: 'YOUR_TENANT_ID',
        clientId: 'YOUR_CLIENT_ID'
        scope: 'openid profile offline_access additional_scope',
        redirectUri: kIsWeb
            // Web app - use the root of your web app here - localhost for local testing
            ? 'http://localhost:8483/'
            // Mobile App
            : 'https://login.live.com/oauth20_desktop.srf',
      ),
    );
    tokenProvider.login();

```

This allows you to pass in an tenant ID, client ID, scope and redirect url. 

The redirect URL will need to vary by native mobile app/web app. The redirect URL is
must be on the web server serving the flutter app on flutter web so that the browser
can access the token. On mobile app, use `https://login.live.com/oauth20_desktop.srf`
as the webview component can see the token in the redirect URL.

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

Under web, currently the AzureLoginWidget always passes through to whenAuthenticated as state tracking
is handled directly by an underlying javascript library from Microsoft. Under web, when a full
interactive auth flow is required, the flutter web app behaviour will vary by version of MSAL
you use:
* MSALv2 (recommended) uses authorization code flow. The implementation uses a Popup window
  so to support browsers that block non-interactive popups you will likely need a login button
  fallback to initiate the sign in flow.
* MSALv1 (deprecated) uses implicit grant flow. The implementation uses browser redirects to
  access the signin page, and will return to the original app once a token is available. To use
  MSALv1 will require setting up an additional client application that supports implicit flows.

Once you have a tokenProvider instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
await tokenProvider.login();
String accessToken = await tokenProvider.getAccessToken();
```



You can also call `getAccessToken()` directly. It will automatically login and retrieve an access token, but may not work on
some web browsers if it is called without user interaction (clicking on a button).

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

On web platform,
* tokens are stored by the underlying msauth.js/msauthv2.js library in the browser localStorage.
* logout initiates the logout flow in the browser, which will forget tokens and logout the browser session.

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

Afterwards you can login and get an access token for accessing other resources. You can also use multiple configs at the same time.

**Help Wanted**: B2C flows have not been enabled in flutter web support yet. If you need this support, please make
the necessary changes and send a pull request.

## Flutter Web Usage

On flutter web, this library supports either authorization code flow or implicit code flow, using version 2 and version 1
of the Microsoft MSAL library respectively. Implicit code flow may have some issues with browsers that don't support
third party cookies, such as Safari, so it is recommended that you use authorization code flow.

**Implicit code flow support will likely be removed in a later version of this library.**

For Flutter Web, to use authorization code flow, add the MSAL v2 js to your `index.html` in the `<head>` section:
```html
  <script type="text/javascript"
    src="https://alcdn.msauth.net/browser/2.13.1/js/msal-browser.min.js"
    integrity="sha384-2Vr9MyareT7qv+wLp1zBt78ZWB4aljfCTMUrml3/cxm0W81ahmDOC6uyNmmn0Vrc"
    crossorigin="anonymous"></script>
  <script src="assets/packages/aad_oauth/assets/msal_authv2.js"></script>
```

For flutter web, to use the older implicit code flow (not recommended), add the MSAL v1 JS to your `index.html` in the `<head>` section:

```html
  <script type="text/javascript" src="https://alcdn.msftauth.net/lib/1.4.8/js/msal.js"
    integrity="sha384-rLIIWk6gwb6EYl6uqmTG4fjUDijpqsPlUxNvjdOcqt/OitOkxXKAJf6HhNEjRDBD"
    crossorigin="anonymous"></script>
  <script src="assets/packages/aad_oauth/assets/msal_auth.js"></script>
```

The `example` app in the project includes both sets of script tags, but MSALv1 is commented out. You cannot use both at the same
time.

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth: "^0.3.0"
```

## Contribution

Contributions can be submitted as pull requests and are highly welcomed. Changes will be bundled together into a release. You can find the next release date and past releases in the [CHANGELOG file](CHANGELOG.md).
