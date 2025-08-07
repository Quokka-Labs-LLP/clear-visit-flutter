import 'package:flutter/material.dart';

import '../utilities/callback_methods.dart';

class CommonButton extends StatelessWidget {
  final VoidToVoidFunc onTap;
  final String btnText;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  const CommonButton(
      {required this.onTap,
      required this.btnText,
      super.key,
      this.fontSize ,
      this.fontColor,
      this.fontWeight,
      this.height,
      this.width});

  @override
  Widget build(final BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return SizedBox(
      height: height ?? 50,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: () => onTap(),

        child: Text(
          btnText,
          style: baseStyle?.copyWith(
            fontSize: fontSize,
            color: fontColor,
            fontWeight: fontWeight,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
