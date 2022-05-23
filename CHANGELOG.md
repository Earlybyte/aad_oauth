## [0.4.0] - 20220523

- Breaking: Use webview_flutter plugin (requires android minSDK >= 20) #121, #124
    - Requires passing the same navigatorKey to Config() and MaterialApp() to support
      interactive login.
    - Removed unnecessary calls to set screen size - calls to these APIs must be
      removed from apps (setWebViewScreenSize and setWebViewScreenSizeFromMedia).
      * webview_flutter automatically adjusts the webview size.
- Update flutter_secure_storage and add android options to config #128, #134

## [0.3.1] - 20200808

- Add flutter_web support [#106](https://github.com/Earlybyte/aad_oauth/pull/106)

## [0.3.0] - 20200725

- Migrate package and examples to sound null safety [#105](https://github.com/Earlybyte/aad_oauth/pull/105)

## [0.2.2] - 20200702

- Add refreshIfAvailable flag to login() [#94](https://github.com/Earlybyte/aad_oauth/pull/94)
- Update Flutter Webview Plugin [#112](https://github.com/Earlybyte/aad_oauth/pull/112)
- Bumped to version 0.2.1 with latest http support [#113](https://github.com/Earlybyte/aad_oauth/pull/113)
- Upgrade packages and fix problems [#114](https://github.com/Earlybyte/aad_oauth/pull/114)

## [0.2.1] - 20210119

- Enable to resize webview after init #68
- Add dartdoc to most important elements #75
- Fix token init #89
- Upgrade plugins #88

## [0.2.0] - 20201007

- Add additional config options #66
- Throw Exception on return #55
- Fix Example App #65
- Comply Pub Dev Requirements #67

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
