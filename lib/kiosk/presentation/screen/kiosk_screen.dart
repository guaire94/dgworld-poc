import 'package:design_system/tokens_color.dart';
import 'package:design_system/tokens_dimens.dart';
import 'package:dgworld_poc/kiosk/presentation/block/kiosk_block.dart';
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
      buildWhen: _buildWhen,
      listenWhen: _listenWhen,
      builder: _onStateChangeBuilder,
      listener: _onStateChangeListener,
    );
  }

  bool _buildWhen(KioskState previous, KioskState current) {
    return current is LoadingState || current is LoadedState;
  }

  bool _listenWhen(KioskState previous, KioskState current) {
    return current is NoInternetErrorState || current is ErrorState;
  }

  Widget _onStateChangeBuilder(
      BuildContext context,
      KioskState state,
      ) {
    Widget body;
    if (state is LoadingState) {
      body = loadingWidget();
    } else if (state is LoadedState) {
      body = Stack(
        children: [
          SliverToBoxAdapter(
            child: InkWell(
              child: Text("Payment success",
                  style: Theme.of(context).textTheme.headline1)
            ),
          ),
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
                    borderRadius: BorderRadius.circular(Dimens.sizeXxs),
                  ),
                  color: DesignColor.colorPrimary100,
                  textColor: DesignColor.colorNeutralWhite,
                  splashColor: DesignColor.colorPrimary100,
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

      if (state is ErrorState) {
        showAlertDialog(
          context,
          title: 'Error',
          description: 'Payment failure',
          buttonText: "Ok",
          onButtonPressed: () {
            dismissDialog(context);
          },
        );
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
