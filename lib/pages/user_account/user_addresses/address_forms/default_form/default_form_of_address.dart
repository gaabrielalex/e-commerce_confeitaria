// ignore_for_file: must_be_immutable

import 'package:brasil_fields/brasil_fields.dart';
import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_dropdown_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultFormOfAddress extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final bool isStream;
  final Stream<dynamic>? stream;
  final void Function()? onSave;
  final void Function()? beforeValidate;
  final void Function(AsyncSnapshot<dynamic>)? beforeBuildingContent;
  final TextEditingController? addressIdentificationController;
  final TextEditingController? recipientController;
  final TextEditingController? zipCodeController;
  final TextEditingController? addressController;
  final TextEditingController? numberController;
  final TextEditingController? complementController;
  final TextEditingController? neighborhoodController;
  final TextEditingController? cityController;
  final TextEditingController? referenceController;
  TextEditingController? selectedStateController;
  bool? disableSaveButton;

  DefaultFormOfAddress({
    super.key,
    required this.formKey,
    required this.title,
    this.isStream = false,
    this.stream,
    this.addressIdentificationController,
    this.recipientController,
    this.zipCodeController,
    this.addressController,
    this.numberController,
    this.complementController,
    this.neighborhoodController,
    this.cityController,
    this.referenceController,
    this.selectedStateController,
    this.onSave,
    this.beforeValidate,
    this.beforeBuildingContent,
    this.disableSaveButton = false,
  });

  @override
  State<DefaultFormOfAddress> createState() => _DefaultFormOfAddressState();
}

class _DefaultFormOfAddressState extends State<DefaultFormOfAddress> {
  @override
  Widget build(BuildContext context) {
    widget.selectedStateController ??= TextEditingController();

    return DefaultLayoutUserAccountPages(
      onPressedBackButton: () => Navigator.pushNamed(context, '/account/addresses'),
      child: DefaultForm(
        formKey: widget.formKey,
        title: widget.title,
        isStream: widget.isStream,
        stream: widget.stream,
        onCancel: () => Navigator.pushNamed(context, '/account/addresses'),
        onSave: widget.disableSaveButton! 
            ? null 
            : () async {
              if(widget.beforeValidate != null) {
                widget.beforeValidate?.call();
              }
              if(widget.formKey.currentState!.validate()) {
                widget.onSave?.call();
              }
            },  
        contentBuilder: (snapshot) {
          if(widget.beforeBuildingContent != null) {
            widget.beforeBuildingContent?.call(snapshot);
          }
          return Wrap(
            runSpacing: ViewUtils.formsGapSize,
            children: [
              CSTextFormField(
                controller: widget.addressIdentificationController,
                labelText: 'Identificação do endereço. Ex: Casa de campo, trabalho, principal, etc.',
                maxLength: 50,
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.recipientController,
                labelText: 'Destinatário',
                maxLength: 100,
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.zipCodeController,
                labelText: 'CEP',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
                validator: AddressService.validateZipCode,
              ),
              CSTextFormField(
                controller: widget.addressController,
                labelText: 'Endereço',
                maxLength: 100,
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.numberController,
                labelText: 'Número',
                maxLength: 5,
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.complementController,
                labelText: 'Complemento (Opcional)',
                maxLength: 200,
              ),
              CSTextFormField(
                controller: widget.neighborhoodController,
                labelText: 'Bairro',
                maxLength: 50,
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.cityController,
                labelText: 'Cidade',
                maxLength: 50,
                validator: ViewUtils.validateRequiredField,
              ),
              CSDropdownButton(
                menuHeight: 210,
                selectedItem: widget.selectedStateController!.text.isEmpty 
                    ? null
                    : widget.selectedStateController!.text,
                labelText: 'Estado',
                items: States.getStatesList(),
                onChanged: (value) {
                  widget.selectedStateController!.text = value!;
                },
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.referenceController,
                labelText: 'Referência (Opcional)',
                maxLength: 200,
              ),
            ],
          );
        },
      ),
    );
  }
}
