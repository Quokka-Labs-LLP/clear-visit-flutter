import 'package:flutter/material.dart';

import '../constants/color_constants.dart';
import '../constants/text_style_constants.dart';
import '../utilities/callback_methods.dart';
import '../utilities/responsive _constants.dart';

class CommonButton extends StatelessWidget {
  final VoidToVoidFunc onTap;
  final String btnText;
  final double? fontSize;
  final Color? fontColor;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? prefixIcon;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CommonButton({
    required this.onTap,
    required this.btnText,
    super.key,
    this.fontSize,
    this.fontColor,
    this.fontWeight,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.prefixIcon,
    this.isLoading = false,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      height: height ?? rpHeight(context, 56),
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => onTap(),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ColorConst.black,
          foregroundColor: fontColor ?? ColorConst.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ?? BorderRadius.circular(rpHeight(context, 28)),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1)
                : BorderSide.none,
          ),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: rpWidth(context, 16)),
        ),
        child: isLoading
            ? SizedBox(
                height: rpHeight(context, 20),
                width: rpHeight(context, 20),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    fontColor ?? ColorConst.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: rpWidth(context, 10)),
                  ],
                  Text(
                    btnText,
                    style:
                        textStyle ??
                        TextStyleConst.titleMediumSemiBold.copyWith(
                          fontSize: fontSize ?? rpHeight(context, 16),
                          color: fontColor ?? ColorConst.white,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
