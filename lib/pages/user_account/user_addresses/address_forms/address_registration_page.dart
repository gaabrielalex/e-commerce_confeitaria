// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_addresses/address_forms/default_form/default_form_of_address.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddressRegistrationPage extends StatefulWidget {
  const AddressRegistrationPage({super.key});

  @override
  State<AddressRegistrationPage> createState() => _AddressRegistrationPageState();
}

class _AddressRegistrationPageState extends State<AddressRegistrationPage> {
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
  bool _disableSaveButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(await _addressService.hasReachedAddressesLimit(Provider.of<UsersServices>(context, listen: false).currentUsersDocRef)) {
        setState(() {
          _disableSaveButton = true;
        });
        Navigator.pushNamed(context, '/account/addresses');
        ViewUtils.hasReachedAddressesLimitScaffoldMessenger(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return DefaultFormOfAddress(
          formKey: _formKey,
          title: 'Novo endereço',
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
          disableSaveButton: _disableSaveButton,
          beforeValidate: () async {
            if(await _addressService.hasReachedAddressesLimit(usersServices.currentUsersDocRef)) {
              ViewUtils.hasReachedAddressesLimitScaffoldMessenger(context);
            }
          },
          onSave: () async {
            bool response = await _addressService.addAddress(Address(
              userRef: usersServices.currentUsersDocRef,
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
                  text: 'Cadastro realizado com sucesso!',
                  actionType: CSSnackBarActionType.success,
                ),
              );
              Navigator.pushReplacementNamed(context, '/account/addresses');
              _formKey.currentState!.reset();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                  text: 'Houve um erro ao realizar o cadastro. Caso o erro persista, entre em contato com o suporte.',
                  actionType: CSSnackBarActionType.error,
                ),
              );
            }
          }
        );
      }
    );
  }
}
