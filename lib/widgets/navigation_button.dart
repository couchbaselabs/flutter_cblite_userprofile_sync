import 'package:flutter/material.dart';

enum NavigationButtonDirection {
  forward,
  backward,
}

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.direction,
  });

  final String label;
  final VoidCallback onPressed;
  final NavigationButtonDirection direction;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
    );

    final iconData = direction == NavigationButtonDirection.forward
        ? Icons.arrow_forward
        : Icons.arrow_back;
    final iconButton = CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xffff0000),
      child: IconButton(
        icon: Icon(iconData),
        color: Colors.white,
        onPressed: onPressed,
      ),
    );

    final Widget first;
    final Widget second;

    if (direction == NavigationButtonDirection.forward) {
      first = text;
      second = iconButton;
    } else {
      first = iconButton;
      second = text;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        first,
        const SizedBox(width: 20),
        second,
      ],
    );
  }
}
