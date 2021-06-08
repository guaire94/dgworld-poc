import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dgworld_poc/kiosk/data/repository/kiosk_repository.dart';
import 'package:dgworld_poc/utils/config.dart';
import 'package:equatable/equatable.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class KioskBloc extends Bloc<KioskEvent, KioskState> {

  KioskBloc({
    this.kioskRepository,
  })  : super(InitialState());
  final KioskRepository kioskRepository;

  @override
  Stream<KioskState> mapEventToState(
      KioskEvent event,
      ) async* {
    if (event is KioskPayEvent) {
      kioskRepository.pay(APIConfig.createPaymentRequest());
      _waitForPaymentResponse();
    } else if (event is KioskWaitForPaymentEvent) {
      yield WaitingForPaymentState(serverIp: event.serverIp, serverPort: event.serverPort);
    } else if (event is KioskPaymentSuccessEvent) {
      yield PaymentSuccessState(referenceNumber: event.referenceNumber, paymentReceipt: event.paymentReceipt, paymentStatus: event.paymentStatus);
    } else if (event is KioskPaymentFailEvent) {
      yield PaymentErrorState();
    }
  }

  void _waitForPaymentResponse() async {
    var app = Router();

    app.post(ServerConfig.PAYMENT_ROUTE, (Request request) async {
      final payload = await request.readAsString();
      final json = jsonDecode(payload);
      final paymentStatus = json["PaymentStatus"];

      if (paymentStatus == "Error") {
        add(KioskPaymentFailEvent());
      } else if (paymentStatus == "Success") {
        final referenceNumber = json["ReferenceNumber"];
        final paymentReceipt = json["PaymentReceipt"];
        final event = KioskPaymentSuccessEvent(referenceNumber: referenceNumber, paymentReceipt: paymentReceipt, paymentStatus: paymentStatus);
        add(event);
      }
      return Response.ok(payload);
    });

    var server = await shelf_io.serve(app, ServerConfig.URL, ServerConfig.PORT);
    add(KioskWaitForPaymentEvent(serverIp: server.address.host, serverPort: server.port.toString()));
  }
}

// Event
abstract class KioskEvent extends Equatable {
  const KioskEvent();
}

class KioskPayEvent extends KioskEvent {
  @override
  List<Object> get props => [];
}

class KioskWaitForPaymentEvent extends KioskEvent {
  KioskWaitForPaymentEvent({
    this.serverIp,
    this.serverPort
  });

  final String serverIp;
  final String serverPort;

  @override
  List<Object> get props => [serverIp, serverPort];
}

class KioskPaymentSuccessEvent extends KioskEvent {
  KioskPaymentSuccessEvent({
    this.referenceNumber,
    this.paymentStatus,
    this.paymentReceipt
  });

  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [referenceNumber, paymentStatus, paymentReceipt];
}

class KioskPaymentFailEvent extends KioskEvent {
  @override
  List<Object> get props => [];
}

// State
abstract class KioskState extends Equatable {
  const KioskState();
}

class InitialState extends KioskState {
  @override
  List<Object> get props => [];
}

class WaitingForPaymentState extends KioskState {
  WaitingForPaymentState({
    this.serverIp,
    this.serverPort
  });

  final String serverIp;
  final String serverPort;

  @override
  List<Object> get props => [serverIp, serverPort];
}

class PaymentSuccessState extends KioskState {
  PaymentSuccessState({
    this.referenceNumber,
    this.paymentStatus,
    this.paymentReceipt
  });

  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [referenceNumber, paymentStatus, paymentReceipt];
}

class PaymentErrorState extends KioskState {
  @override
  List<Object> get props => [];
}

class NoInternetErrorState extends KioskState {
  @override
  List<Object> get props => [];
}
