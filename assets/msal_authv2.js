// Create the main myMSALObj instance
// configuration parameters are located at authConfig.js
let myMSALObj = null;

let username = "";

// Add scopes here for access token to be used at Microsoft Graph API endpoints.
const tokenRequest = {
    scopes: null
};

// Initialise the myMSALObj for the given client, authority and scope
function initialiseMSAL(clientId, authority, scope, redirectUri) {
    var msalConfig = {
        auth: {
            clientId: clientId,
            authority: authority,
            redirectUri: redirectUri,
        },
        cache: {
            cacheLocation: "localStorage",
            storeAuthStateInCookie: false,
        }
    };

    if (typeof scope === "string") {
        tokenRequest.scopes = scope.split(" ");
    } else {
        tokenRequest.scopes = scope;
    }

    myMSALObj = new msal.PublicClientApplication(msalConfig);

}

function handleResponse(resp) {
    // This is called after signIn completes
    if (resp !== null) {
        username = resp.account.username;
    } else {
        console.warn("handleResponse got null resp");
    }
}


function signout() {
    if (username) {
        const logoutRequest = {
            account: myMSALObj.getAccountByUsername(username)
        };

        myMSALObj.logout(logoutRequest);
    }
}

function getTokenPopup(request) {
    /**
     * See here for more info on account retrieval:
     * https://github.com/AzureAD/microsoft-authentication-library-for-js/blob/dev/lib/msal-common/docs/Accounts.md
     */
    request.account = myMSALObj.getAccountByUsername(username);
    return myMSALObj.acquireTokenSilent(request).catch(error => {
        console.warn("silent token acquisition fails. acquiring token using popup");
        if (error instanceof msal.InteractionRequiredAuthError) {
            // fallback to interaction when silent call fails
            return myMSALObj.acquireTokenPopup(request).then(tokenResponse => {
                console.log(tokenResponse);

                return tokenResponse;
            }).catch(error => {
                console.error(error);
            });
        } else {
            console.warn(error);
        }
    });
}

function getAccount() {
    if (username !== "") {
        return username;
    }
    const currentAccounts = myMSALObj.getAllAccounts();
    if (currentAccounts === null) {
        return;
    } else if (currentAccounts.length > 1) {
        // Multiple users - pick the first one, but this shouldn't happen
        console.warn("Multiple accounts detected.");
        username = currentAccounts[0].username;
    } else if (currentAccounts.length === 1) {
        username = currentAccounts[0].username;
    }
    return username;
}

function GetBearerToken(tokenCallback, errorCallback) {

    if (!getAccount()) {
        myMSALObj.loginPopup(loginRequest).then(
            function (loginResponse) {
                username = loginResponse.account.username;
                return tokenCallback({
                    accessToken: loginResponse.accessToken,
                    expiresOn: loginResponse.expiresOn.getTime()
                });
            }
        ).catch(error => {
            console.error(error);
            errorCallback(error.errorCode);
        });
        return
    }

    getTokenPopup(tokenRequest).then(response => {
        return tokenCallback({
            accessToken: response.accessToken,
            expiresOn: response.expiresOn.getTime()
        });
    }).catch(error => {
        console.error(error);
        errorCallback(error.errorCode);
    });
}