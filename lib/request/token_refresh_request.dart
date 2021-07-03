import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/request/request_details.dart';

class TokenRefreshRequestDetails extends RequestDetails {
  TokenRefreshRequestDetails(AadConfig config, String refreshToken)
      : super(
          uri: Uri.parse(config.tokenUrl),
          parameters: {
            'client_id': config.clientId,
            'scope': config.scope,
            'redirect_uri': config.redirectUri,
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken
          },
          headers: {
            'Accept': 'application/json',
            'Content-Type': AadConfig.contentType
          },
        ) {
    setParametersFromConfig('client_secret', config.clientSecret);
  }
}
