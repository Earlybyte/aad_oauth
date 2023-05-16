# Changelog

## [Unreleased]

## [0.4.4] - 20230516

- Add cacheLocation configuration https://github.com/Earlybyte/aad_oauth/pull/220 (by @tigloo)
- Always use myMSALObj.acquireTokenSilent to get fresh token https://github.com/Earlybyte/aad_oauth/pull/226 (by @ruicraveiro)
- Added custom domain url with tenant Id for B2C with Azure Front Door https://github.com/Earlybyte/aad_oauth/pull/227 (by @jochemvanweelde)
- Check navigator state https://github.com/Earlybyte/aad_oauth/pull/229 (by @easazade)

## [0.4.3] - 20230327

- Adding postLogoutRedirectUri - Sign-out with a redirect https://github.com/Earlybyte/aad_oauth/pull/217
- Update flutter_secure_storage to 8.0.0 https://github.com/Earlybyte/aad_oauth/pull/216
- Refresh authResult from cache in getAccessToken and getIdToken https://github.com/Earlybyte/aad_oauth/pull/215
- Add `hasCachedAccountInformation` getter support https://github.com/Earlybyte/aad_oauth/pull/210
- Custom parameters to support dynamic UI customization for B2C custom policies https://github.com/Earlybyte/aad_oauth/pull/207

## [0.4.2] - 20230124

- Add MockCoreOAuth for testing https://github.com/Earlybyte/aad_oauth/pull/185.
- Update flutter_secure_storage to ^7.0.1, bump minor dependency versions https://github.com/Earlybyte/aad_oauth/pull/192
- Fix request code issue in google signIn https://github.com/Earlybyte/aad_oauth/pull/193
- Add optional parameter origin header for mobile token request https://github.com/Earlybyte/aad_oauth/pull/177
- Fix net::ERR_CACHE_MISS on release https://github.com/Earlybyte/aad_oauth/pull/198
- Update Webview https://github.com/Earlybyte/aad_oauth/pull/199
- Add Azure B2C support for Flutter Web https://github.com/Earlybyte/aad_oauth/pull/201

## [0.4.1] - 20221124

- Added web redirect authentication flow option https://github.com/Earlybyte/aad_oauth/pull/174.
  - Must use at least version 2.13.1 of MSAL library from MS in index.html.
  - Calculates an appropriate default redirect URI on mobile and web if not provided.
- Add userAgent parameter to WebView https://github.com/Earlybyte/aad_oauth/pull/181
- Fix exception behavior for the web version https://github.com/Earlybyte/aad_oauth/pull/170.
- Breaking: Improve exceptions handling https://github.com/Earlybyte/aad_oauth/pull/168.
- Fix login error when changing user password https://github.com/Earlybyte/aad_oauth/pull/164.
- Add loader while render web page in WebView https://github.com/Earlybyte/aad_oauth/pull/162.

## [0.4.0] - 20220523

- Breaking: Use webview_flutter plugin (requires android minSDK >= 20) https://github.com/Earlybyte/aad_oauth/pull/121, https://github.com/Earlybyte/aad_oauth/pull/124
- Requires passing the same navigatorKey to Config() and MaterialApp() to support
  interactive login.
- Removed unnecessary calls to set screen size - calls to these APIs must be
  removed from apps (setWebViewScreenSize and setWebViewScreenSizeFromMedia).
  - webview_flutter automatically adjusts the webview size.
- Update flutter_secure_storage and add android options to config https://github.com/Earlybyte/aad_oauth/pull/128, https://github.com/Earlybyte/aad_oauth/pull/134

## [0.3.1] - 20200808

- Add flutter_web support https://github.com/Earlybyte/aad_oauth/pull/106

## [0.3.0] - 20200725

- Migrate package and examples to sound null safety https://github.com/Earlybyte/aad_oauth/pull/105

## [0.2.2] - 20200702

- Add refreshIfAvailable flag to login() https://github.com/Earlybyte/aad_oauth/pull/94
- Update Flutter Webview Plugin https://github.com/Earlybyte/aad_oauth/pull/112
- Bumped to version 0.2.1 with latest http support https://github.com/Earlybyte/aad_oauth/pull/113
- Upgrade packages and fix problems https://github.com/Earlybyte/aad_oauth/pull/114

## [0.2.1] - 20210119

- Enable to resize webview after init https://github.com/Earlybyte/aad_oauth/pull/68
- Add dartdoc to most important elements https://github.com/Earlybyte/aad_oauth/pull/75
- Fix token init https://github.com/Earlybyte/aad_oauth/pull/89
- Upgrade plugins https://github.com/Earlybyte/aad_oauth/pull/88

## [0.2.0] - 20201007

- Add additional config options https://github.com/Earlybyte/aad_oauth/pull/66
- Throw Exception on return https://github.com/Earlybyte/aad_oauth/pull/55
- Fix Example App https://github.com/Earlybyte/aad_oauth/pull/65
- Comply Pub Dev Requirements https://github.com/Earlybyte/aad_oauth/pull/67

## [0.1.9] - 20200529

- Added id_token support https://github.com/Earlybyte/aad_oauth/pull/36
- Added support to AAD B2C https://github.com/Earlybyte/aad_oauth/pull/35

## [0.1.8] - 20200203

- Fix requested bug on auth cancel
- Modified to take into account Api permission in Azure AD rather than de default one

## [0.1.7] - 20190430

- Expose Redirect URL property in config.dart file to public https://github.com/Earlybyte/aad_oauth/pull/9
- Expose webview rect area to public for customization https://github.com/Earlybyte/aad_oauth/pull/12

## [0.1.6] - 20190419

- Fix Token Refresh URL

## [0.1.5] - 20190413

- Fix Token expiration issue https://github.com/Earlybyte/aad_oauth/issues/5
- Remove old token on iOS after fresh install https://github.com/Earlybyte/aad_oauth/issues/3

## [0.1.4] - 20190325

- Change from memory cache to secure storage

## [0.1.3] - 20190212

- Fix iOS issue by encoding the URL
- Change dependency of example to local library

## [0.1.2] - 20181229

- Added example README

## [0.1.1] - 20181229

- Added an example

## [0.1.0] - 20181229

- Adjusted library interface
- Bug fixing

## [0.0.1] - 20181228

- Initial release
