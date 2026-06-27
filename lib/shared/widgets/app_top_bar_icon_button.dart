import 'package:flutter/material.dart';

const double kAppTopBarIconButtonSize = 44;
const double kAppTopBarIconVisualSize = 24;
const double kAppTopBarHorizontalPadding = 16;

class AppTopBarIconButton extends StatelessWidget {
  const AppTopBarIconButton({
    super.key,
    required this.onTap,
    required this.child,
    this.size = kAppTopBarIconButtonSize,
    this.borderRadius = kAppTopBarIconButtonSize / 2,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(child: child),
        ),
      ),
    );
  }
}
