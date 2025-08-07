import 'package:flutter/cupertino.dart';

double widthBaseScale = 0.0;
double heightBaseScale = 0.0;

void calculateScale(BuildContext context) {
  MediaQueryData mediaQuery = MediaQuery.of(context);
  double screenWidth = mediaQuery.size.width;
  double screenHeight = mediaQuery.size.height;
  widthBaseScale = screenWidth / 390; // base width as per design
  heightBaseScale = screenHeight / 844; // base height as per design
}

double normalize(double size, String based) {
  double newSize = (based == 'height') ? size * heightBaseScale : size * widthBaseScale;
  return newSize;
}

double rpHeight(BuildContext context, double size) {
  calculateScale(context);
  return normalize(size, 'height');
}
double rpWidth(BuildContext context, double size) {
  calculateScale(context);
  return normalize(size, 'width');
}
