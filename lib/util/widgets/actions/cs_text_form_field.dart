// ignore_for_file: must_be_immutable

import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_dark_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';

class CSTextFormField extends StatefulWidget {
  final Key? textFormFieldKey;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int? maxLength;
  bool obscureText;
  bool iconToggleObscureText;
  bool? enabled;
  void Function(String)? onChanged;
  bool disableBottomMarginDefault;
  final int? maxLines;

  CSTextFormField({
    this.controller,
    this.textFormFieldKey,
    this.labelText,
    this.hintText,
    //Valor padrão ser uma string vazia faz com que quando o validator
    //for acionado, a msg de erro não vai quebrar o layout
    //pois é com se aquele espaço já estivesse reservado
    this.helperText = '',
    this.disableBottomMarginDefault = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
    this.maxLength,
    this.obscureText = false,
    this.iconToggleObscureText = false,
    this.enabled,
    this.onChanged,
    this.maxLines = 1,
    super.key,
  });

  @override
  State<CSTextFormField> createState() => _CSTextFormFieldState();
}

class _CSTextFormFieldState extends State<CSTextFormField> {
  final Icon _disabledObscureIcon = const LineIcon.eye();
  final Icon _enabledObscureIcon = const LineIcon.eyeSlash();

  @override
  Widget build(BuildContext context) {
    if (widget.disableBottomMarginDefault && widget.helperText == '') {
        widget.helperText = null;
    }
    
    return SizedBox(
      /* Com o height definido, a mensagem de erro que aparece abaixo
      do input ao validar o formulário quebra o formato do input*/
      height: widget.validator == null && widget.maxLength == null
          ? CSDarkTheme.inputHeight
          : null,
      child: TextFormField(
        key: widget.textFormFieldKey,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator,
        maxLength: widget.maxLength,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        cursorColor: CSColors.primary.color,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          counterText: '',
          suffixIcon: widget.iconToggleObscureText
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      widget.obscureText = !widget.obscureText;
                    });
                  },
                  icon: widget.obscureText
                      ? _enabledObscureIcon
                      : _disabledObscureIcon,
                )
              : widget.suffixIcon,
        ).applyDefaults(CSDarkTheme.specificInputDecorationTheme),
        onChanged: widget.onChanged,
      ),
    );
  }
}
