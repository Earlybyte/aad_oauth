# Azure Active Directory OAuth

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:
 - [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as plattform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Afterwards you have to initialize the library as follow:

```dart
final Config config = new Config(
  "YOUR TENANT ID",
  "YOUR CLIENT ID",
  "openid profile offline_access");
final AadOAuth oauth = new AadOAuth(config);
```

This allows you to pass in an tenant ID, client ID and scope.

Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` to retrieve an access token:

```dart
await oauth.login();
String accessToken = await oauth.getAccessToken();
```

You can also call `getAccessToken()` directly. It will automatically login and retrive an access token.

Tokens are cached in memory. to destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

## Installation

Add the following to your pubspec.yaml dependencies:

```yaml
dependencies:
  aad_oauth: "^0.1.1"
```

