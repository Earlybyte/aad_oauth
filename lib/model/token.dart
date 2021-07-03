import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Access token enabling to securely call protected APIs on behalf of the user.
@immutable
class Token extends Equatable {
  Token(
      {dynamic accessToken,
      dynamic tokenType,
      dynamic refreshToken,
      required this.issueTimeStamp,
      dynamic idToken,
      dynamic expiresIn,
      dynamic expireTimeStamp})
      : accessToken = accessToken is String ? accessToken : '',
        refreshToken = refreshToken is String ? refreshToken : '',
        tokenType = tokenType is String ? tokenType : '',
        idToken = idToken is String ? idToken : '',
        expiresIn = expiresIn == null
            ? 60
            : expiresIn is int
                ? expiresIn
                : int.tryParse(expiresIn.toString()) ?? 60 {
    this.expireTimeStamp =
        getExpiryTimeStamp(issueTimeStamp, expireTimeStamp, this.expiresIn);
  }

  static DateTime getExpiryTimeStamp(
      DateTime issueTimeStamp, dynamic expireTimeStamp, int expiresIn) {
    final expire = expireTimeStamp != null
        ? DateTime.fromMillisecondsSinceEpoch(expireTimeStamp)
            .add(Duration(seconds: -_expireOffSetSeconds))
        : issueTimeStamp
            .add(Duration(seconds: expiresIn - _expireOffSetSeconds));
    if (MaximumExpirySeconds > 0) {
      final maxExpire =
          issueTimeStamp.add(Duration(seconds: MaximumExpirySeconds));
      if (maxExpire.isBefore(expire)) {
        return maxExpire;
      }
    }
    return expire;
  }

  /// offset for expiry so we look for a new token before the expiry time
  static const _expireOffSetSeconds = 10;

  // To debug token refresh, we can force the maximum expiry time low
  // Must set this to a positive number of seconds to activate
  static int MaximumExpirySeconds = -1;

  /// The requested access token. The app can use this token to authenticate to the secured resource, such as a web API.
  final String accessToken;

  /// Indicates the token type value. The only type that Azure AD supports is Bearer.
  final String tokenType;

  /// An OAuth 2.0 refresh token. The app can use this token acquire additional access tokens after the current access token expires. Refresh_tokens are long-lived, and can be used to retain access to resources for extended periods of time. For more detail on refreshing an access token, refer to the section below.
  /// Note: Only provided if offline_access [scope] was requested.
  final String refreshToken;

  /// A JSON Web Token (JWT). The app can decode the segments of this token to request information about the user who signed in.
  /// The app can cache the values and display them, and confidential clients can use this for authorization.
  /// For more information about id_tokens, see the id_token reference.
  /// Note: Only provided if openid [scope] was requested.
  final String idToken;

  /// Current time when token was issued.
  final DateTime issueTimeStamp;

  /// Predicted token expiration time.
  late final DateTime expireTimeStamp;

  /// How long the access token is valid (in seconds).
  final int expiresIn;

  /// JSON map to Token factory.
  factory Token.fromJson(Map<String, dynamic> json) => Token.fromMap(json);

  /// Convert this Token to JSON map.
  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  /// Convert Token to JSON map.
  static Map toJsonMap(Token model) {
    var ret = {};
    if (model.accessToken != '') {
      ret['access_token'] = model.accessToken;
    }
    if (model.tokenType != '') {
      ret['token_type'] = model.tokenType;
    }
    if (model.refreshToken != '') {
      ret['refresh_token'] = model.refreshToken;
    }
    ret['expires_in'] = model.expiresIn;
    ret['expire_timestamp'] = model.expireTimeStamp.millisecondsSinceEpoch;
    if (model.idToken != '') {
      ret['id_token'] = model.idToken;
    }
    return ret;
  }

  /// Convert JSON map to Token.
  static Token fromMap(Map map) {
    //error handling as described in https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#error-response-1
    if (map['error'] != null) {
      throw Exception('Error during token request: ' +
          map['error'] +
          ': ' +
          map['error_description']);
    }

    var model = Token(
        issueTimeStamp: DateTime.now().toUtc(),
        expireTimeStamp: map['expire_timestamp'],
        expiresIn: map['expires_in'],
        idToken: map['id_token'],
        accessToken: map['access_token'],
        refreshToken: map['refresh_token'],
        tokenType: map['token_type']);

    return model;
  }

  /// Check if Access Token is set and not expired.
  /// For unit testing, allow optional passing of time
  /// which should not be in UTC
  bool hasValidAccessToken([DateTime? atTime]) {
    return accessToken != '' &&
        expireTimeStamp.isAfter((atTime ?? DateTime.now()).toUtc());
  }

  /// Check if Refresh Token is set.
  bool hasRefreshToken() {
    return refreshToken != '';
  }

  @override
  List<Object?> get props => [
        Token,
        tokenType,
        accessToken,
        idToken,
        refreshToken,
        expiresIn,
        expireTimeStamp,
        issueTimeStamp,
      ];
}
