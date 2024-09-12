// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_addresses/address_forms/default_form/default_form_of_address.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';

class AddressEditPage extends StatefulWidget {
  final String? addressId;

  const AddressEditPage({
    super.key,
    required this.addressId,
  });

  @override
  State<AddressEditPage> createState() => _AddressEditPageState();
}

class _AddressEditPageState extends State<AddressEditPage> {
  final AddressService _addressService = AddressService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressIdentification = TextEditingController();
  final TextEditingController _recipient = TextEditingController();
  final TextEditingController _zipCode = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _complement = TextEditingController();
  final TextEditingController _neighborhood = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _selectedState = TextEditingController();
  final TextEditingController _reference = TextEditingController();
  Address? addressToUpdate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (addressToUpdate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CSSnackBar(
              text:
                  'Erro ao carregar endereço. Verifique sua conexão com a internet ou se acessou a página corretamente.',
              actionType: CSSnackBarActionType.error,
            ),
          );
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeAsyncData();
  }

  Future<void> _initializeAsyncData() async {
  
    try {
      final snapshot = await _addressService.getAddressById(widget.addressId!);
      addressToUpdate = (snapshot != null) ? Address.fromJson(snapshot) : null;
    } catch (e) {
      debugPrint(e.toString());
      return;
    }

    setState(() {
      _addressIdentification.text = addressToUpdate!.addressIdentification!;
      _recipient.text = addressToUpdate!.recipient!;
      _zipCode.text = addressToUpdate!.zipCode!;
      _address.text = addressToUpdate!.address!;
      _number.text = addressToUpdate!.number!;
      _complement.text = addressToUpdate!.complement!;
      _neighborhood.text = addressToUpdate!.neighborhood!;
      _city.text = addressToUpdate!.city!;
      _selectedState.text = addressToUpdate!.state!;
      _reference.text = addressToUpdate!.reference!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultFormOfAddress(
      formKey: _formKey,
      title: 'Editar endereço',
      addressIdentificationController: _addressIdentification,
      recipientController: _recipient,
      zipCodeController: _zipCode,
      addressController: _address,
      numberController: _number,
      complementController: _complement,
      neighborhoodController: _neighborhood,
      cityController: _city,
      selectedStateController: _selectedState,
      referenceController: _reference,
      onSave: () async {
        if (addressToUpdate == null) {
          return;
        }
        bool response = await _addressService.updateAddress(
            addressToUpdate!.id!,
            Address(
              userRef: addressToUpdate!.userRef,
              addressIdentification: _addressIdentification.text,
              recipient: _recipient.text,
              zipCode: _zipCode.text,
              address: _address.text,
              number: _number.text,
              complement: _complement.text,
              neighborhood: _neighborhood.text,
              city: _city.text,
              state: _selectedState.text,
              reference: _reference.text,
            ));
        if (response) {
          ScaffoldMessenger.of(context).showSnackBar(
            CSSnackBar(
              text: 'Endereço atualizado com sucesso!',
              actionType: CSSnackBarActionType.success,
            ),
          );
          // Navigator.pushNamed(context, '/account/addresses');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            CSSnackBar(
              text:
                  'Houve um erro ao atualizar o endereço. Caso o erro persista, entre em contato com o suporte.',
              actionType: CSSnackBarActionType.error,
            ),
          );
        }
      },
    );
  }
}