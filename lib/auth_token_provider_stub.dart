import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/repository/aad_token_repository_stub.dart';

import 'package:aad_oauth/auth_token_provider.dart';

AuthTokenProvider getAuthTokenProvider(
        String AzureTenantId, String clientId, String openIdScope) =>
    AuthTokenProvider(tokenRepository: AadTokenRepositoryStub());

AuthTokenProvider getAuthTokenProviderFromConfig(AadConfig config) =>
    AuthTokenProvider(tokenRepository: AadTokenRepositoryStub());
