// Needs to be a var at the top level to get hoisted to global scope.
// https://stackoverflow.com/questions/28776079/do-let-statements-create-properties-on-the-global-object/28776236#28776236
var aadOauth = (function () {
  let myMSALObj = null;
  let authResult = null;
  let redirectHandlerTask = null;

  const tokenRequest = {
    scopes: null,
    prompt: null,
    extraQueryParameters: {}
  };

  // Initialise the myMSALObj for the given client, authority and scope
 function init(config) {
     // TODO: Add support for other MSAL configuration
     var authData = {
         clientId: config.clientId,
         authority: config.isB2C ? "https://" + config.tenant + ".b2clogin.com/" + config.tenant + ".onmicrosoft.com/" + config.policy + "/" : "https://login.microsoftonline.com/" + config.tenant,
         redirectUri: config.redirectUri,
     };
     var postLogoutRedirectUri = {
         postLogoutRedirectUri: config.postLogoutRedirectUri,
     };
     var msalConfig = {
         auth: config?.postLogoutRedirectUri == null ? {
             ...authData,
         } : {
             ...authData,
             ...postLogoutRedirectUri,
         },
         cache: {
             cacheLocation: config.cacheLocation,
             storeAuthStateInCookie: false,
         },
     };

     if (typeof config.scope === "string") {
         tokenRequest.scopes = config.scope.split(" ");
     } else {
         tokenRequest.scopes = config.scope;
     }

     tokenRequest.extraQueryParameters = JSON.parse(config.customParameters);
     tokenRequest.prompt = config.prompt;

     myMSALObj = new msal.PublicClientApplication(msalConfig);
     // Register Callbacks for Redirect flow and record the task so we
     // can await its completion in the login API

     redirectHandlerTask = myMSALObj.handleRedirectPromise();
 }

  // Tries to silently acquire a token. Will return null if a token
  // could not be acquired or if no cached account credentials exist.
  // Will return the authentication result on success and update the
  // global authResult variable.
  async function silentlyAcquireToken() {
    const account = getAccount();
    if (account == null) {
      return null;
    }

    try {
      // Silent acquisition only works if the access token is either
      // within its lifetime, or the refresh token can successfully be
      // used to refresh it. This will throw if the access token can't
      // be acquired.
      const silentAuthResult = await myMSALObj.acquireTokenSilent({
        scopes: tokenRequest.scopes,
        prompt: "none",
        account: account,
        extraQueryParameters: tokenRequest.extraQueryParameters
      });

      return  authResult = silentAuthResult;
    } catch (error) {
      console.log('Unable to silently acquire a new token: ' + error.message)
      return null;
    }

  }

  /// Authorize user via refresh token or web gui if necessary.
  ///
  /// Setting [refreshIfAvailable] to [true] should attempt to re-authenticate
  /// with the existing refresh token, if any, even though the access token may
  /// still be valid; however MSAL doesn't support this. Therefore it will have
  /// the same impact as when it is set to [false]. 
  /// [useRedirect] uses the MSAL redirection based token acquisition instead of
  /// a popup window. This is the only way that iOS based devices will acquire
  /// a token using MSAL when the application is installed to the home screen.
  /// This is because the popup window operates outside the sandbox of the PWA and
  /// won't share cookies or local storage with the PWA sandbox. Redirect flow works
  /// around this issue by having the MSAL authentication take place directly within
  /// the PWA sandbox browser.
  /// The token is requested using acquireTokenSilent, which will refresh the token
  /// if it has nearly expired. If this fails for any reason, it will then move on
  /// to attempt to refresh the token using an interactive login.

  async function login(refreshIfAvailable, useRedirect, onSuccess, onError) {
    try {
      // The redirect handler task will complete with auth results if we
      // were redirected from AAD. If not, it will complete with null
      // We must wait for it to complete before we allow the login to
      // attempt to acquire a token silently, and then progress to interactive
      // login (if silent acquisition fails).
      let result = await redirectHandlerTask;
      if (result !== null) {
        authResult = result;
      }
    }
    catch (error) {
      authResultError = error;
      onError(authResultError);
      return;
    }

    // Try to sign in silently, assuming we have already signed in and have
    // a cached access token
    await silentlyAcquireToken()

    if(authResult != null) {
      // Skip interactive login
      onSuccess(authResult.accessToken ?? null);
      return
    }

    const account = getAccount()
      
    if (useRedirect) {
      myMSALObj.acquireTokenRedirect({
        scopes: tokenRequest.scopes,
        prompt: tokenRequest.prompt,
        account: account,
        extraQueryParameters: tokenRequest.extraQueryParameters
      });
    } else {
      // Sign in with popup
      try {        
        const interactiveAuthResult = await myMSALObj.loginPopup({
          scopes: tokenRequest.scopes,
          prompt: tokenRequest.prompt,
          account: account,
          extraQueryParameters: tokenRequest.extraQueryParameters
        });

        authResult = interactiveAuthResult;

        onSuccess(authResult.accessToken ?? null);
      } catch (error) {
        // rethrow
        console.warn(error.message);
        onError(error);
      }
    }
  }

  function getAccount() {
    // If we have recently authenticated, we use the auth'd account;
    // otherwise we fallback to using MSAL APIs to find cached auth
    // accounts in browser storage.
    if (authResult !== null && authResult.account !== null) {
      return authResult.account
    }

    const currentAccounts = myMSALObj.getAllAccounts();

    if (currentAccounts === null || currentAccounts.length === 0) {
      return null;
    } else if (currentAccounts.length > 1) {
      // Multiple users - pick the first one, but this shouldn't happen
      console.warn("Multiple accounts detected, selecting first.");

      return currentAccounts[0];
    } else if (currentAccounts.length === 1) {
      return currentAccounts[0];
    }
  }

  function logout(onSuccess, onError) {
    const account = getAccount();

    if (!account) {
      onSuccess();
      return;
    }

    authResult = null;
    authResultError = null;
    tokenRequest.scopes = null;
    myMSALObj
      .logout({ account: account })
      .then((_) => onSuccess())
      .catch(onError);
  }

  async function getAccessToken() {
    var result = await silentlyAcquireToken()
    return result ? result.accessToken : null;
  }

  async function getIdToken() {
    var result = await silentlyAcquireToken()
    return result ? result.idToken : null;
  }

  function hasCachedAccountInformation() {
    return getAccount() != null;
  }

  return {
    init: init,
    login: login,
    logout: logout,
    getIdToken: getIdToken,
    getAccessToken: getAccessToken,
    hasCachedAccountInformation: hasCachedAccountInformation,
  };
})();
