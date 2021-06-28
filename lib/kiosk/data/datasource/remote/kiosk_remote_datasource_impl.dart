import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';
import 'package:dgworld_poc/utils/config.dart';
import 'package:dio/dio.dart';

import 'kiosk_remote_datasource.dart';

class KioskRemoteDataSourceImpl extends KioskRemoteDataSource {

  @override
  Future<bool> pay(String posIp, KioskPaymentRequest request) async {
    final Dio dio = Dio();
    final url = "http://${posIp}:${APIConfig.PORT}${APIConfig.PAY_ROUTE}";

    try {
      final Response response = await dio.post(url, data: request.toJson());
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> check(String posIp) async {
    final Dio dio = Dio();
    final url = "http://${posIp}:${APIConfig.PORT}${APIConfig.CHECK_ROUTE}";

    try {
      final Response response = await dio.get(url);
      return response.statusCode == 200;
    } catch(e) {
      print(e.toString());
      return false;
    }
  }
}