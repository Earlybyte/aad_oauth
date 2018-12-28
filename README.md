# Azure Active Directory OAuth

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint for your apps. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:
 - [Authorization code flow (including refresh token)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)

## Usage

Performing authorization for an API is straight forward using this library. In most cases you
will just be able to use the following approach:

```dart
    final String azureClientId = "YOUR_CLIENT_ID";
    final String azureTennant = "YOUR_TENANT_ID";
    final Config oAuthConfig = new Config(
      "https://login.microsoftonline.com/$azureTennant/oauth2/v2.0/authorize",
      "https://login.microsoftonline.com/$azureTennant/oauth2/v2.0/token",
      azureClientId,
      "https://login.live.com/oauth20_desktop.srf",
      "code",
      "openid profile offline_access",
      contentType: "application/x-www-form-urlencoded");
    final AadOAuth oauth = new AadOAuth(oAuthConfig);
```

This allows you to pass in an Authorization URL, Token request URL, Client ID, Redirect URL, Response Type (always "code"), Scope
and the content type (always "application/x-www-form-urlencoded").

Then once you have an OAuth instance, you can simply call `getAccessToken()` method to retrieve a access token:

```dart
String accessToken = await oauth.getAccessToken();
```

`getAccessToken()` will perform necessary authentication steps (full authorization code flow or just refresh code flow).

Tokens are cached in memory. If you want to destroy the tokens you can call `logout()`

```dart
    await oauth.logout();
```

## Installation

Add the following you your pubspec.yaml dependancies:

```yaml
dependencies:
  aad_oauth: "^0.0.1"
```

