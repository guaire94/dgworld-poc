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
      yield PaymentSuccessState(
          posOrderId: event.posOrderId,
          transactionId: event.transactionId,
          talabatOrderId: event.talabatOrderId,
          referenceNumber: event.referenceNumber,
          paymentReceipt: event.paymentReceipt,
          paymentStatus: event.paymentStatus
      );
    } else if (event is KioskPaymentDeclineEvent) {
      yield PaymentDeclineState(paymentStatus: event.paymentStatus, errorMessage: event.errorMessage);
    } else if (event is KioskPaymentRejectedEvent) {
      yield PaymentRejectedState(paymentStatus: event.paymentStatus);
    } else if (event is KioskPaymentErrorEvent) {
      yield PaymentErrorState(paymentStatus: event.paymentStatus);
    }
  }

  void _waitForPaymentResponse() async {
    var app = Router();

    app.post(ServerConfig.PAYMENT_ROUTE, (Request request) async {
      final payload = await request.readAsString();
      final json = jsonDecode(payload);
      final paymentStatus = json["PaymentStatus"];

      if (paymentStatus == "Success") {
        final posOrderId = json["POSOrderId"];
        final transactionId = json["TransactionId"];
        final talabatOrderId = json["TalabatOrderId"];
        final referenceNumber = json["ReferenceNumber"];
        final paymentReceipt = json["PaymentReceipt"];
        final event = KioskPaymentSuccessEvent(
            posOrderId: posOrderId,
            transactionId: transactionId,
            talabatOrderId: talabatOrderId,
            referenceNumber: referenceNumber,
            paymentReceipt: paymentReceipt,
            paymentStatus: paymentStatus
        );
        add(event);
      } else if (paymentStatus == "Decline") {
        final errorMessage = json["ErrorMessage"];
        add(KioskPaymentDeclineEvent(paymentStatus: paymentStatus, errorMessage: errorMessage));
      } else if (paymentStatus == "Rejected") {
        add(KioskPaymentRejectedEvent(paymentStatus: paymentStatus));
      } else if (paymentStatus == "Error") {
        add(KioskPaymentErrorEvent(paymentStatus: paymentStatus));
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
    this.posOrderId,
    this.transactionId,
    this.talabatOrderId,
    this.referenceNumber,
    this.paymentStatus,
    this.paymentReceipt
  });

  final String posOrderId;
  final String transactionId;
  final String talabatOrderId;
  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [posOrderId, transactionId, talabatOrderId, referenceNumber, paymentStatus, paymentReceipt];
}

class KioskPaymentDeclineEvent extends KioskEvent {
  KioskPaymentDeclineEvent({
    this.paymentStatus,
    this.errorMessage
  });

  final String paymentStatus;
  final String errorMessage;

  @override
  List<Object> get props => [paymentStatus, errorMessage];
}

class KioskPaymentRejectedEvent extends KioskEvent {
  @override
  KioskPaymentRejectedEvent({
    this.paymentStatus
  });

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

class KioskPaymentErrorEvent extends KioskEvent {
  @override
  KioskPaymentErrorEvent({
    this.paymentStatus
  });

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
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
    this.posOrderId,
    this.transactionId,
    this.talabatOrderId,
    this.referenceNumber,
    this.paymentStatus,
    this.paymentReceipt
  });

  final String posOrderId;
  final String transactionId;
  final String talabatOrderId;
  final String referenceNumber;
  final String paymentStatus;
  final String paymentReceipt;

  @override
  List<Object> get props => [posOrderId, transactionId, talabatOrderId, referenceNumber, paymentStatus, paymentReceipt];
}

class PaymentDeclineState extends KioskState {
  PaymentDeclineState({
    this.paymentStatus,
    this.errorMessage
  });

  final String paymentStatus;
  final String errorMessage;

  @override
  List<Object> get props => [paymentStatus, errorMessage];
}

class PaymentRejectedState extends KioskState {
  @override
  PaymentRejectedState({
    this.paymentStatus
  });

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

class PaymentErrorState extends KioskState {
  @override
  PaymentErrorState({
    this.paymentStatus
  });

  final String paymentStatus;

  @override
  List<Object> get props => [paymentStatus];
}

class NoInternetErrorState extends KioskState {
  @override
  List<Object> get props => [];
}
