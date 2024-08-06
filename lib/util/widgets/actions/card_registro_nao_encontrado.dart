import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:flutter/material.dart';

class CardRegistroNaoEncontrado extends StatelessWidget {
  final String registerName;

  const CardRegistroNaoEncontrado({
    super.key,
    required this.registerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 64),
      alignment: Alignment.center,
      child: Text(
        "$registerName não encontrado!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: CSColors.primary.color,
          fontSize: Responsive.isDesktop(context) ? 20 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
