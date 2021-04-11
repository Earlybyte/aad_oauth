import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository.dart';
import 'package:aad_oauth/auth_token_provider.dart';

class MobileAzureTokenProvider extends AuthTokenProvider {
  MobileAzureTokenProvider(String AzureTenantId, String clientId, String scope)
      : super(
          tokenRepository: AadTokenRepository(
            config: AadConfig(
              tenant: AzureTenantId,
              clientId: clientId,
              scope: 'openid profile offline_access ${scope}',
              redirectUri: 'https://login.live.com/oauth20_desktop.srf',
            ),
          ),
        );
  MobileAzureTokenProvider.config(AadConfig config)
      : super(
          tokenRepository: AadTokenRepository(config: config),
        );
}

AuthTokenProvider getAuthTokenProviderFromConfig(AadConfig config) =>
    MobileAzureTokenProvider.config(config);

AuthTokenProvider getAuthTokenProvider(String AzureTenantId, String clientId,
        String openIdScope, String redirectUri) =>
    MobileAzureTokenProvider(AzureTenantId, clientId, openIdScope);
