# aad-b2c-oauth-example

A Flutter OAuth package example for performing user authentication against Azure Active Directory with B2C OAuth2 v2.0 endpoint.

## Usage

Setup your B2C directory - [Azure AD B2C Setup](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant/).
<br></br>Register an App on the previously created B2C directory - [Azure AD B2C App Register](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-register-applications?tabs=applications).
<br></br>Use native app as plattform type (with callback URL: https://login.live.com/oauth20_desktop.srf).
<br></br>Create your user flows - [Azure AD B2C User Flows](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-user-flows)

Add your Azure tenant ID, tenantName, client ID (ID of App), client Secret (Secret of App) and redirectUrl in the main.dart source-code:

```dart
static final Config configB2C = new Config(
    "YOUR_TENANT_ID",
    "YOUR_CLIENT_ID",
    "YOUR_CLIENT_ID offline_access",
    "https://login.live.com/oauth20_desktop.srf",
    clientSecret: "YOUR_CLIENT_SECRET",
    isB2C: true,
    azureTennantName: "YOUR_TENANT_NAME",
    userFlow: "YOUR_USER_FLOW",
  );
```

Afterwards you can login and get an access token for accessing other resources.
