import 'package:aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defaults Android secure storage to automatic cipher migration', () {
    final config = Config(
      tenant: 'tenant',
      clientId: 'client-id',
      scope: 'openid',
      navigatorKey: GlobalKey<NavigatorState>(),
    );

    expect(
      config.aOptions.toMap(),
      containsPair('migrateOnAlgorithmChange', 'true'),
    );
    expect(
      config.aOptions.toMap(),
      containsPair('encryptedSharedPreferences', 'false'),
    );
  });
}
