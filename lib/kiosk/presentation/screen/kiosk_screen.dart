import 'package:dgworld_poc/kiosk/presentation/bloc/kiosk_bloc.dart';
import 'package:dgworld_poc/libraries/common/presentation/talabat_utility_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KioskScreen extends StatefulWidget {
  @override
  _KioskScreenState createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  KioskBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<KioskBloc>();
  }

  void _pay() {
    _dispatch(KioskPayEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DGWorld - POC'),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    return BlocConsumer<KioskBloc, KioskState>(
      builder: _onStateChangeBuilder,
      listener: _onStateChangeListener,
    );
  }

  Widget _onStateChangeBuilder(
      BuildContext context,
      KioskState state,
      ) {
    Widget body;
    if (state is WaitingForPaymentState) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Wait for POST request on \n" + state.serverUrl + "/dgworldpos/payment"),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("ServerUrl: " + state.serverUrl),
          )
        ],
      );
    } else if (state is PaymentSuccessState) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("Payment Status -> " + state.paymentStatus),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("POS Order Id -> " + state.posOrderId),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Talabat Order Id -> " + state.talabatOrderId),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Reference Number -> " + state.referenceNumber),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Transaction Id -> " + state.transactionId),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Payment Receipt -> " + state.paymentReceipt),
          )
        ],
      );
    } else if (state is PaymentDeclineState) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("Payment Status -> " + state.paymentStatus),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child:  Text("Error Message -> " + state.errorMessage)
          )
        ],
      );
    } else if (state is SyncErrorState) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("POS terminal not sync with the tablet. Trying to sync again..."),
          )
        ],
      );
    } else if (state is PaymentRejectedState) {
      body = Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Text("Payment Status -> " + state.paymentStatus),
          )
        ],
      );
    } else {
      body = Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                child:  Text(
                  'Tap on the button will make a api call to DGWorld POS and make wait for payment status',
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child:  FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color:  Colors.orange,
                  textColor: Colors.white,
                  splashColor: Colors.orange,
                  onPressed: _pay,
                  child: Text('Try payment',
                      style: Theme.of(context).textTheme.button),
                ),
              ),
            ],
          )
      );
    }

    return SafeArea(child: body);
  }

  Function _onStateChangeListener(
      BuildContext context,
      KioskState state,
      ) {
    return (context, state) {
      if (state is NoInternetErrorState) {
        showAlertDialog(
          context,
          title: 'Error',
          description: 'No internet',
          buttonText: "Ok",
          onButtonPressed: () {
            dismissDialog(context);
          },
        );
        return;
      }
    };
  }

  void _dispatch(KioskEvent event) {
    bloc.add(event);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}
