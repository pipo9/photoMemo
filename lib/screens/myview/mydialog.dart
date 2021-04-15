import 'package:flutter/material.dart';

class MyDialog {
  static void circularProgressStart(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
              ),
            ));
  }

  static void circularProgressStop(BuildContext context) {
    Navigator.pop(context);
  }

  static void info({
    @required BuildContext context,
    @required String title,
    @required String content,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: Theme.of(context).textTheme.button),
          )
        ],
      ),
    );
  }

  static void alert(
      {@required BuildContext context,
      @required String title,
      @required Function action}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        actions: [
          FlatButton(
            onPressed: () {
              action();
            },
            child: Text('Yes', style: Theme.of(context).textTheme.button),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: Theme.of(context).textTheme.button),
          )
        ],
      ),
    );
  }
}
