import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context,
    {@required String title,
    @required String description,
    @required String buttonText,
    @required Function onButtonPressed}) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: description != null ? Text(description) : null,
            actions: [
              FlatButton(
                onPressed: () => onButtonPressed(),
                child: Text(buttonText),
              )
            ],
          ));
}

void showLoading(BuildContext context, String text) {
  AlertDialog alert = AlertDialog(
    content: Row(
      children: [
        const CircularProgressIndicator(),
        Container(margin: const EdgeInsets.only(left: 16), child: Text(text)),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void hideLoading(BuildContext context) {
  Navigator.pop(context);
}

void dismissDialog(context) {
  Navigator.of(context).pop();
}

Widget loadingWidget() => const Center(child: CircularProgressIndicator());

Widget emptyWidget() => Container();