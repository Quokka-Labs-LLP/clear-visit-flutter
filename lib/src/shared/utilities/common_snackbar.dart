import 'package:another_flushbar/flushbar.dart';
import 'package:base_architecture/src/shared/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';

class SnackBarHelper {
  static Flushbar? _currentFlushBar;
  static bool isSnackBarShowing = false;

  static Future<void> showSuccessSnackBar({
    required BuildContext context,
    required String message,
  }) async {
    try {
      if (isSnackBarShowing) {
        if(_currentFlushBar?.isShowing() ?? false) {
          await _currentFlushBar?.dismiss();
        }
      } else {
        isSnackBarShowing = true;
        _currentFlushBar = Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          flushbarStyle: FlushbarStyle.GROUNDED,
          backgroundColor: ColorConst.grey60,
          messageText: Column(
            children: [
              Image.asset('assets/images/common/tick_24.png'),
              const SizedBox(
                height: 5,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorConst.white, fontSize: 14),
              )
            ],
          ),
          duration: const Duration(seconds: 3),
        );
        if (context.mounted) {
          await _currentFlushBar?.show(context);
        }
      }
    } catch (e) {
      debugPrint('Error showing FlushBar: $e');
    } finally {
      Future.delayed(const Duration(seconds: 2)).then(
            (value) {
          _currentFlushBar = null;
          isSnackBarShowing = false;
        },
      );
    }
  }
}