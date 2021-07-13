import 'package:dgworld_poc/kiosk/data/datasource/remote/kiosk_remote_datasource.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_print_invoice_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_validate_request.dart';
import 'package:flutter/foundation.dart';

import 'kiosk_repository.dart';

class KioskRepositoryImpl extends KioskRepository {
  KioskRepositoryImpl({
    @required remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final KioskRemoteDataSource _remoteDataSource;

  // DGWorld endpoint
  @override
  Future<bool> pay(String posUrl, KioskPaymentRequest request) async {
    // return true; // Only on case of local testing
    try {
      final result = await _remoteDataSource.pay(posUrl, request);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> printReceipt(String posUrl, KioskPrintRequest request) async {
    // return true; // Only on case of local testing
    try {
      final result = await _remoteDataSource.printReceipt(posUrl, request);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> check(String posUrl) async {
    try {
      final result = await _remoteDataSource.check(posUrl);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // TalabatPay endpoint
  @override
  Future<bool> validate(KioskValidateRequest request) async {
    try {
      final result = await _remoteDataSource.validate(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }
}