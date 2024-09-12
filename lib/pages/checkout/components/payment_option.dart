import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  BooleanController onSelected;

  PaymentOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Duração da animação
      color: onSelected.value ? Colors.grey[300] : Colors.transparent,
      child: ListTile(
        leading: Icon(icon,
            color: onSelected.value
                ? CSColors.primarySwatchV1.color
                : CSColors.primary.color),
        title: Text(
          label,
          style: TextStyle(
              color: onSelected.value
                  ? CSColors.primarySwatchV1.color
                  : CSColors.primary.color),
        ),
        onTap: () {
          onSelected.toggle();
        },
      ),
    );
  }
}
