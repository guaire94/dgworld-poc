import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_print_invoice_request.dart';
import 'package:dgworld_poc/kiosk/data/dto/kiosk_validate_request.dart';
import 'package:dgworld_poc/utils/config.dart';
import 'package:dio/dio.dart';

import 'kiosk_remote_datasource.dart';

class KioskRemoteDataSourceImpl extends KioskRemoteDataSource {

  @override
  Future<bool> pay(String posUrl, KioskPaymentRequest request) async {
    final Dio dio = Dio();
    final url = "${posUrl}${APIConfig.PAY_ROUTE}";

    try {
      final Response response = await dio.post(url, data: request.toJson());
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> printReceipt(String posUrl, KioskPrintRequest request) async {
    final Dio dio = Dio();
    final url = "${posUrl}${APIConfig.PRINT_ROUTE}";

    try {
      final Response response = await dio.post(url, data: request.toJson());
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> check(String posUrl) async {
    final Dio dio = Dio();
    final url = "${posUrl}${APIConfig.CHECK_ROUTE}";

    try {
      final Response response = await dio.get(url);
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> validate(KioskValidateRequest request) async {
    final Dio dio = Dio();
    final url = "https://expo2020pay-qa.dhhmena.com/${APIConfig.VALIDATE_ROUTE}";

    try {
      final Response response = await dio.post(url, data: request.toJson());
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }
}