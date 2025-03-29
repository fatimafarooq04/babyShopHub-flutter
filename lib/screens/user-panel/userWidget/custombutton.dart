import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double width;

  final IconData? icon;
  final bool isOutlined;
  const Custombutton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 50,
    this.width = 100,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              border:
                  isOutlined
                      ? Border.all(color: AppConstants.primaryColor, width: 2)
                      : null,
              color: isOutlined ? Colors.transparent : AppConstants.buttonBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: isOutlined ? Colors.black : Colors.white,
                    size: 24,
                  ),
                Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isOutlined ? Colors.black : Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
