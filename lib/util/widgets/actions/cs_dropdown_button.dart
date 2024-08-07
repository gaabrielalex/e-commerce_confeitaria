// ignore_for_file: must_be_immutable

import 'package:confeitaria_divine_cacau/util/styles/cs_dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class CSDropdownButton extends StatefulWidget {
  final double menuHeight;
  String? selectedItem;
  final String? labelText;
  final String? hintText;
  String? helperText;
  final String? errorText;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  bool disableBottomMarginDefault;

  CSDropdownButton({
    super.key,
    this.menuHeight = 245,
    required this.items,
    this.selectedItem,
    this.labelText,
    this.hintText,
    //Valor padrão ser uma string vazia faz com que quando o validator
    //for acionado, a msg de erro não vai quebrar o layout
    //pois é com se aquele espaço já estivesse reservado
    this.helperText = '',
    this.disableBottomMarginDefault = false,
    this.errorText,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CSDropdownButton> createState() => _CSDropdownButtonState();
}

class _CSDropdownButtonState extends State<CSDropdownButton> {
  @override
  void initState() {
    super.initState();
    if (widget.disableBottomMarginDefault && widget.helperText == '') {
      widget.helperText = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: widget.selectedItem,
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: widget.onChanged,
      validator: widget.validator,
      alignment: Alignment.center,
      isExpanded: true,
      menuMaxHeight: widget.items.length <= 5 ? null : widget.menuHeight,
      icon: const Icon(
        LineIcons.angleDown,
        size: 18.0,
      ),
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        counterText: '',
        focusColor: Colors.transparent,
      ).applyDefaults(CSDarkTheme.specificInputDecorationTheme),
    );
  }
}
