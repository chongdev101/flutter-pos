import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SecurityDialog {
  static bool _isShowing = false;

  static void show({
    required String title,
    required String message,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                _isShowing = false;
                Get.back();
                SystemNavigator.pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void resetForTesting() {
    _isShowing = false;
  }

  static void reset() {
    _isShowing = false;
  }
}
