import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color borderColor;
  final double height;
  final double width;

  const CardButton({
    Key? key,
    required this.icon,
    required this.size,
    required this.color,
    required this.borderColor,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            blurRadius: 10.0,
            offset: const Offset(0, 8.0),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}

