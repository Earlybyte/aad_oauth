/// Access token enabling to securely call protected APIs on behalf of the user.
class Token {
  /// Offset which is subtracted from expire time
  final expireOffSet = 5;

  /// The requested access token. The app can use this token to authenticate to the secured resource, such as a web API.
  String? accessToken;

  /// Indicates the token type value. The only type that Azure AD supports is Bearer.
  String? tokenType;

  /// An OAuth 2.0 refresh token. The app can use this token acquire additional access tokens after the current access token expires. Refresh_tokens are long-lived, and can be used to retain access to resources for extended periods of time. For more detail on refreshing an access token, refer to the section below.
  /// Note: Only provided if offline_access `scope` was requested.
  String? refreshToken;

  /// A JSON Web Token (JWT). The app can decode the segments of this token to request information about the user who signed in.
  /// The app can cache the values and display them, and confidential clients can use this for authorization.
  /// For more information about id_tokens, see the id_token reference.
  /// Note: Only provided if openid `scope` was requested.
  String? idToken;

  /// Current time when token was issued.
  late DateTime issueTimeStamp;

  /// Predicted token expiration time.
  DateTime? expireTimeStamp;

  /// How long the access token is valid (in seconds).
  int? expiresIn;

  /// Access token enabling to securely call protected APIs on behalf of the user.
  Token();

  /// JSON map to Token factory.
  factory Token.fromJson(Map<String, dynamic>? json) => Token.fromMap(json);

  /// Convert this Token to JSON map.
  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  /// Convert Token to JSON map.
  static Map toJsonMap(Token model) {
    var ret = {};
    if (model.accessToken != null) {
      ret['access_token'] = model.accessToken;
    }
    if (model.tokenType != null) {
      ret['token_type'] = model.tokenType;
    }
    if (model.refreshToken != null) {
      ret['refresh_token'] = model.refreshToken;
    }
    if (model.expiresIn != null) {
      ret['expires_in'] = model.expiresIn;
    }
    if (model.expireTimeStamp != null) {
      ret['expire_timestamp'] = model.expireTimeStamp!.millisecondsSinceEpoch;
    }
    if (model.idToken != null) {
      ret['id_token'] = model.idToken;
    }
    return ret;
  }

  /// Convert JSON map to Token.
  static Token fromMap(Map<String, dynamic>? map) {
    if (map == null) throw Exception('No token from received');
    //error handling as described in https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#error-response-1
    if (map['error'] != null) {
      throw Exception('Error during token request: ' +
          map['error'] +
          ': ' +
          map['error_description']);
    }

    var model = Token();
    model.accessToken = map['access_token'];
    model.tokenType = map['token_type'];
    model.expiresIn = map['expires_in'] is int
        ? map['expires_in']
        : int.tryParse(map['expires_in'].toString()) ?? 60;
    model.refreshToken = map['refresh_token'];
    model.idToken = map.containsKey('id_token') ? map['id_token'] : '';
    model.issueTimeStamp = DateTime.now().toUtc();
    model.expireTimeStamp = map.containsKey('expire_timestamp')
        ? DateTime.fromMillisecondsSinceEpoch(map['expire_timestamp'])
        : model.issueTimeStamp
            .add(Duration(seconds: model.expiresIn! - model.expireOffSet));

    return model;
  }

  /// Check if Access Token is set and not expired.
  bool hasValidAccessToken() {
    return accessToken != null &&
        expireTimeStamp != null &&
        expireTimeStamp!.isAfter(DateTime.now().toUtc());
  }

  /// Check if Refresh Token is set.
  bool hasRefreshToken() {
    return refreshToken != null;
  }
}
