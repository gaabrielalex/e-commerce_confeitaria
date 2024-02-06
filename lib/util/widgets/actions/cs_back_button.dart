import 'package:flutter/material.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';   

class CSBackButton extends StatelessWidget {
  final void Function()? onPressed;

  const CSBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_outlined),
      iconSize: 25,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(CSColors.foregroundV2.color),
        padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
      ),
    );
  }
}
