import 'package:dgworld_poc/kiosk/data/dto/kiosk_payment_request.dart';

abstract class KioskRepository {
  Future<void> pay(KioskPaymentRequest request);
}