# aad-oauth-example

A Flutter OAuth package example for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint.

## Usage

Register an App in the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as plattform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Add your Azure tenant ID and client ID (ID of App) in the main.dart source-code:

```dart
static final Config config = new Config("YOUR_TENANT_ID", "YOUR CLIENT ID", "openid profile offline_access");
```

Afterwards you can login and get an access token for accessing other resources.