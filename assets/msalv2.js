// Needs to be a var at the top level to get hoisted to global scope.
// https://stackoverflow.com/questions/28776079/do-let-statements-create-properties-on-the-global-object/28776236#28776236
var aadOauth = (function () {
  let myMSALObj = null;
  let authResult = null;

  const tokenRequest = {
    scopes: null,
    // Hardcoded?
    prompt: null,
  };

  // Initialise the myMSALObj for the given client, authority and scope
  function init(config) {
    var msalConfig = {
      auth: {
        clientId: config.clientId,
        authority: config.isB2C
          ? "https://" + config.tenant + ".b2clogin.com/" + config.tenant + ".onmicrosoft.com/" + config.policy + "/"
          : "https://login.microsoftonline.com/" + config.tenant,
        redirectUri: config.redirectUri,
      },
      cache: {
        cacheLocation: "localStorage",
        storeAuthStateInCookie: false,
      },
    };

    if (typeof config.scope === "string") {
      tokenRequest.scopes = config.scope.split(" ");
    } else {
      tokenRequest.scopes = config.scope;
    }

    tokenRequest.prompt = config.prompt;

    myMSALObj = new msal.PublicClientApplication(msalConfig);
  }

  async function login(refreshIfAvailable, onSuccess, onError) {
    // Try to sign in silently
    if (refreshIfAvailable) {
      try {
        // I think we want to skip the prompt option here.
        const silentAuthResult = await myMSALObj.acquireTokenSilent({
          scopes: tokenRequest.scopes,
          prompt: "none",
        });

        authResult = silentAuthResult;

        // Skip interactive login
        onSuccess();

        return;
      } catch {
        // Swallow errors and continue to interactive login
      }
    }

    // Sign in with popup
    try {
      const interactiveAuthResult = await myMSALObj.loginPopup({
        scopes: tokenRequest.scopes,
        prompt: tokenRequest.prompt,
      });

      authResult = interactiveAuthResult;

      onSuccess();
    } catch (error) {
      // rethrow
      onError(error);
    }
  }

  function getAccount() {
    const currentAccounts = myMSALObj.getAllAccounts();

    if (currentAccounts === null || currentAccounts.length === 0) {
      return;
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
    tokenRequest.scopes = null;
    myMSALObj
      .logout({ account: account })
      .then((_) => onSuccess())
      .catch(onError);
  }

  function getAccessToken() {
    return authResult ? authResult.accessToken : null;
  }

  function getIdToken() {
    return authResult ? authResult.idToken : null;
  }

  function isLogged() {
    return getAccount() !== undefined;
  }

  return {
    init: init,
    login: login,
    logout: logout,
    getIdToken: getIdToken,
    getAccessToken: getAccessToken,
    isLogged: isLogged,
  };
})();
