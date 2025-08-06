import 'package:flutter/material.dart';

extension SafeScreenSize on BuildContext {
  double get safeHeight =>
      MediaQuery.of(this).size.height -
          MediaQuery.of(this).padding.top - MediaQuery.of(this).padding.bottom;

  double get safeWidth =>
      MediaQuery.of(this).size.width -
          MediaQuery.of(this).padding.left -
          MediaQuery.of(this).padding.right;
}
