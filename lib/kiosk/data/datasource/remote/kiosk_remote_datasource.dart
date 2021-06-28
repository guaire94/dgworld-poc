
import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';

abstract class KioskRemoteDataSource {
  Future<void> pay(String posIp, KioskPaymentRequest request);
}