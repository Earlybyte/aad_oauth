import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/request/request_details.dart';

class TokenRequestDetails extends RequestDetails {
  TokenRequestDetails(AadConfig config, String code)
      : super(
          uri: Uri.parse(config.tokenUrl),
          parameters: {
            'client_id': config.clientId,
            'grant_type': 'authorization_code',
            'scope': config.scope,
            'code': code,
            'redirect_uri': config.redirectUri,
          },
          headers: {
            'Accept': 'application/json',
            'Content-Type': AadConfig.contentType
          },
        ) {
    setParametersFromConfig('resource', config.resource);
    setParametersFromConfig('client_secret', config.clientSecret);
    setParametersFromConfig('code_verifier', config.codeVerifier);
  }
}
