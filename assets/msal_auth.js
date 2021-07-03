var myMSALObj = null;
// this can be used for login or token request, however in more complex situations
// this can have diverging options
var requestObj = null;
function authRedirectCallBack(error, response) {
    if (error) {
        console.log(error);
    } else {
        if (response.tokenType === "id_token" && myMSALObj.getAccount() && !myMSALObj.isCallback(window.location.hash)) {
            console.log('id_token acquired at: ' + new Date().toString());
        } else if (response.tokenType === "access_token") {
            console.log('access_token acquired at: ' + new Date().toString());
        } else {
            console.log('Unknown access response type ' + response.tokenType);
        }
    }
}


// Initialise the myMSALObj for the given client, authority and scope
function initialiseMSAL(clientId, authority, scope) {
    var msalConfig = {
        auth: {
            clientId: clientId,
            authority: authority,
        },
        cache: {
            cacheLocation: "localStorage",
            storeAuthStateInCookie: false,
        }
    };

    // this can be used for login or token request, however in more complex situations
    // this can have diverging options
    requestObj = {
        scopes: [scope]
    };

    myMSALObj = new Msal.UserAgentApplication(msalConfig);
    myMSALObj.handleRedirectCallback(authRedirectCallBack);
    // Register Callbacks for redirect flow - (IE only)
}


function requiresInteraction(errorCode) {
    if (!errorCode || !errorCode.length) {
        return false;
    }
    return errorCode === "consent_required" ||
        errorCode === "interaction_required" ||
        errorCode === "login_required";
}


function GetBearerToken(tokenCallback, errorCallback) {
    if (!myMSALObj.getAccount()) {
        myMSALObj.loginRedirect(requestObj)
        return
    }

    myMSALObj.acquireTokenSilent(requestObj).then(function (tokenResponse) {
        return tokenCallback({
            accessToken: tokenResponse.accessToken,
            expiresOn: tokenResponse.expiresOn.getTime()
        });
    }).catch(function (error) {
        console.log(error.errorCode);
        // Upon acquireTokenSilent failure (due to consent or interaction or login required ONLY)
        // Call acquireTokenRedirect
        if (requiresInteraction(error)) {
            myMSALObj.acquireTokenRedirect(requestObj)
            return
        } else {
            console.log("Failed to acquire token because error code is not for an interactive requirement" + error.errorCode)
            errorCallback(error);
            alert("Unable to sign in: " + error)
        }
    })
}

function signout() {
    myMSALObj.logout();
}

function logToken(token) {
    //console.log(token)
}

function logError(error) {
    console.log("Error: " + error)
}
