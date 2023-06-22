import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  // Variables
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? borderRadius;

  const DefaultButton(
      {Key? key, required this.child,
      required this.onPressed,
      this.width,
      this.height,
      this.borderRadius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        child: child,
        style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 28.0))),
        onPressed: onPressed,
      ),
    );
  }
}
