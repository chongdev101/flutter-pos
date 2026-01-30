import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/app_navigator.dart';

class SecurityDialog {
  static bool _isShowing = false;

  static void show({
    required String title,
    required String message,
  }) {
    if (_isShowing) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _isShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  _isShowing = false;

                  // ปิด dialog อย่างปลอดภัย
                  Navigator.of(context, rootNavigator: true).pop();

                  // 🔥 Hard block: ปิดแอพทันที
                  SystemNavigator.pop();
                },
                child: const Text('ตกลง'),
              ),
            ],
          ),
        );
      },
    );
  }

  static void resetForTesting() {
    _isShowing = false;
  }
}
