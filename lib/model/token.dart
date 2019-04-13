class Token {

  //offset is subtracted from expire time
  final expireOffSet = 5;

  String accessToken;
  String tokenType;
  String refreshToken;
  DateTime issueTimeStamp;
  DateTime expireTimeStamp;
  int expiresIn;

  Token();

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token.fromMap(json);

  Map toMap() => Token.toJsonMap(this);

  @override
  String toString() => Token.toJsonMap(this).toString();

  static Map toJsonMap(Token model) {
    Map ret = new Map();
    if (model != null) {
      if (model.accessToken != null) {
        ret["access_token"] = model.accessToken;
      }
      if (model.tokenType != null) {
        ret["token_type"] = model.tokenType;
      }
      if (model.refreshToken != null ) {
        ret["refresh_token"] = model.refreshToken;
      }
      if (model.expiresIn != null ) {
        ret["expires_in"] = model.expiresIn;
      }
      if (model.expireTimeStamp != null ) {
        ret["expire_timestamp"] = model.expireTimeStamp.millisecondsSinceEpoch;
      }    
    }
    return ret;
  }

  static Token fromMap(Map map) {
    if (map == null)
      throw new Exception("No token from received");
    //error handling as described in https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow#error-response-1
    if ( map["error"] != null )
      throw new Exception("Error during token request: " + map["error"] + ": " + map["error_description"]);

    Token model = new Token();
    model.accessToken = map["access_token"];
    model.tokenType = map["token_type"];
    model.expiresIn = map["expires_in"];
    model.refreshToken = map["refresh_token"];
    model.issueTimeStamp = new DateTime.now().toUtc();
    model.expireTimeStamp = map.containsKey("expire_timestamp") ? DateTime.fromMillisecondsSinceEpoch(map["expire_timestamp"]) : model.issueTimeStamp.add(new Duration(seconds: model.expiresIn-model.expireOffSet));
    return model;
  }

  static bool isExpired(Token token) {
    return token.expireTimeStamp.isBefore(new DateTime.now().toUtc());
  }

  static bool tokenIsValid(Token token) {
    return token != null && !Token.isExpired(token) && token.accessToken != null;
  }
}