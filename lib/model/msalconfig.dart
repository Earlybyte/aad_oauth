/// Microsoft identity platform authentication library.
@JS()
library msauth;

import 'package:js/js.dart';

/// Interop with JS, we need to convert Config to a JS object or it comes
/// through as empty when passed to JS.
///
/// Parameters according to official Microsoft Documentation:
/// - Azure AD https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow
/// - Azure AD B2C: https://docs.microsoft.com/en-us/azure/active-directory-b2c/authorization-code-flow
///
/// DartDocs of parameters are mostly from those pages.
@JS()
@anonymous
class MsalConfig {
  /// Azure AD authorization URL.
  String? authorizationUrl;

  /// Azure AD token URL.
  String? tokenUrl;

  /// The tenant value in the path of the request can be used to control who can sign into the application.
  /// The allowed values are common, organizations, consumers, and tenant identifiers. Or Name of your Azure AD B2C tenant.
  String? tenant;

  /// __AAD B2C only__: The user flow to be run. Specify the name of a user flow you've created in your Azure AD B2C tenant.
  /// For example: b2c_1_sign_in, b2c_1_sign_up, or b2c_1_edit_profile
  String? policy;

  /// The Application (client) ID that the Azure portal – App registrations experience assigned to your app.
  String? clientId;

  /// Must include code for the authorization code flow.
  String? responseType;

  /// The redirect uri of your app, where authentication responses can be sent and received by your app.
  /// It must exactly match one of the redirect_uris you registered in the portal, except it must be url encoded.
  /// For native & mobile apps, you should use the default value.
  String? redirectUri;

  /// A space-separated list of scopes that you want the user to consent to.
  /// For the /authorize leg of the request, this can cover multiple resources, allowing your app to get consent for multiple web APIs you want to call.
  String? scope;

  /// Specifies the method that should be used to send the resulting token back to your app.
  /// Can be one of the following:
  /// - query
  /// - fragment
  /// - form_post
  String? responseMode;

  /// A value included in the request that will also be returned in the token response.
  /// It can be a string of any content that you wish.
  /// A randomly generated unique value is typically used for preventing cross-site request forgery attacks.
  /// The value can also encode information about the user's state in the app before the authentication request occurred, such as the page or view they were on.
  String? state;

  /// Indicates the type of user interaction that is required.
  /// The only valid values at this time are *login*, *none*, and *consent*.
  String? prompt;

  /// Used to secure authorization code grants via Proof Key for Code Exchange (PKCE).
  /// Required if [codeChallengeMethod] is included.
  /// For more information, see the PKCE RFC.
  /// This is now recommended for all application types - native apps, SPAs, and confidential clients like web apps.
  String? codeChallenge;

  /// The method used to encode the code_verifier for the code_challenge parameter.
  /// This SHOULD be S256, but the spec allows the use of plain if for some reason the client cannot support SHA256.
  /// If excluded, code_challenge is assumed to be plaintext if [codeChallenge] is included.
  /// Microsoft identity platform supports both plain and S256.
  /// For more information, see the PKCE RFC.
  /// This is required for single page apps using the authorization code flow.
  String? codeChallengeMethod;

  ///	Can be used to pre-fill the username/email address field of the sign-in page for the user, if you know their username ahead of time.
  /// Often apps will use this parameter during re-authentication, having already extracted the username from a previous sign-in using the preferred_username claim.
  String? loginHint;

  /// If included, it will skip the email-based discovery process that user goes through on the sign-in page, leading to a slightly more streamlined user experience - for example, sending them to their federated identity provider.
  /// Often apps will use this parameter during re-authentication, by extracting the tid from a previous sign-in.
  /// If the tid claim value is 9188040d-6c67-4c5b-b112-36a304b66dad, you should use domain_hint=consumers.
  /// Otherwise, use domain_hint=organizations.
  String? domainHint;

  /// __AAD B2C only__: A nonce is a strategy used to mitigate token replay attacks.
  /// Your application can specify a nonce in an authorization request by using the nonce query parameter.
  /// The value you provide in the request is emitted unmodified in the nonce claim of an ID token only.
  /// This claim allows your application to verify the value against the value specified on the request.
  /// Your application should perform this validation during the ID token validation process.
  String? nonce;

  /// __AAD B2C only__: Identifies access tokens, to allow multiple concurrent sessions.
  String? tokenIdentifier;

  /// The client secret that you generated for your app in the app registration portal.
  String? clientSecret;

  /// The same code_verifier that was used to obtain the authorization_code.
  /// Required if PKCE was used in the authorization code grant request.
  /// For more information, see the PKCE RFC.
  String? codeVerifier;

  /// Resource
  String? resource;

  /// Using Azure AD B2C instead of standard Azure AD.
  /// Azure Active Directory B2C provides business-to-customer identity as a service.
  bool? isB2C;

  /// Azure AD OAuth Configuration. Look at individual fields for description.
  external factory MsalConfig.construct(
      {String? tenant,
      String? policy,
      String? clientId,
      String? responseType,
      String? redirectUri,
      String? scope,
      String? responseMode,
      String? state,
      String? prompt,
      String? codeChallenge,
      String? codeChallengeMethod,
      String? nonce,
      String? tokenIdentifier,
      String? clientSecret,
      String? resource,
      bool? isB2C,
      String? loginHint,
      String? domainHint,
      String? codeVerifier,
      String? authorizationUrl,
      String? tokenUrl});
}
