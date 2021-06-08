import 'package:dgworld_poc/kiosk/data/datasource/remote/kiosk_remote_datasource.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:flutter/foundation.dart';

import 'kiosk_repository.dart';

class KioskRepositoryImpl extends KioskRepository {
  KioskRepositoryImpl({
    @required remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final KioskRemoteDataSource _remoteDataSource;

  @override
  Future<void> pay(KioskPaymentRequest request) async {
    try {
      final result = await _remoteDataSource.pay(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}