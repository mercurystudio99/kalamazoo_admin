import 'package:flutter/material.dart';
import 'package:kalamazoo_app_dashboard/utils/globals.dart' as globals;

class DefaultButton extends StatelessWidget {
  // Variables
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? borderRadius;
  final int? level;
  final String? type;

  const DefaultButton(
      {Key? key,
      required this.child,
      required this.onPressed,
      this.width,
      this.height,
      this.borderRadius,
      this.level,
      this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        child: child,
        style: ElevatedButton.styleFrom(
            backgroundColor: (globals.restaurantType == type && level == 1)
                ? Colors.white
                : Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 28.0))),
        onPressed: onPressed,
      ),
    );
  }
}
