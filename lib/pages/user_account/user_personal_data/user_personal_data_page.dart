// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:brasil_fields/brasil_fields.dart';
import 'package:confeitaria_divine_cacau/models/users/users.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_dropdown_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/date_chooser_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserPersonalDataPage extends StatefulWidget {
  const UserPersonalDataPage({super.key});

  @override
  State<UserPersonalDataPage> createState() => _UserPersonalDataPageState();
}

class _UserPersonalDataPageState extends State<UserPersonalDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _cpf = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final BooleanController _isAdmin = BooleanController(); 
  String? _selectedGender;
  String? _emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return DefaultLayoutUserAccountPages(
          child: DefaultForm(
            formKey: _formKey,
            title: 'Dados pessoais',
            isStream: true,
            stream: usersServices.currentUsersStream,
            onCancel: () => Navigator.pushNamed(context, '/account/overview'),
            onSave: () async {
              _emailErrorText = await usersServices.validateEmail(_email.text, isUpdate: true);
              bool dataIsValid = _formKey.currentState!.validate();

              if(dataIsValid) {
                var result = await usersServices.updateUserData( usersServices.currentUsers!.id!, Users(
                  userName: _userName.text,
                  email: _email.text,
                  cpf: _cpf.text,
                  gender: _selectedGender,
                  birthday: _birthday.text.isNotEmpty
                      ? DateFormat("dd/MM/yyyy").parse(_birthday.text)
                      : null,
                  phone: _phone.text,
                  isAdmin: _isAdmin.value,
                ));
                if(result.status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CSSnackBar(
                      text: 'Dados atualizados com sucesso!',
                      actionType: CSSnackBarActionType.success,
                    ),
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CSSnackBar(
                      text: result.message ?? 'Erro ao atualizar os dados, tente novamente mais tarde, permanecendo o erro, entre em contato com o suporte.',
                      actionType: CSSnackBarActionType.error,
                    ),
                  );
                }
              }
            },
            contentBuilder: (snapshot) {
              Users users = Users.fromJson(snapshot.data!);
              _userName.text = users.userName!;
              _email.text = users.email!;
              _cpf.text = users.cpf!;
              if(users.gender != null) _selectedGender = users.gender!;
              _birthday.text = users.birthday != null
                  ? DateFormat("dd/MM/yyyy").format(users.birthday!)
                  : '';
              _phone.text = users.phone!;
              _isAdmin.set(users.isAdmin!);

              return Wrap(
                runSpacing: ViewUtils.formsGapSize,
                children: [ 
                  CSTextFormField(
                    controller: _userName,
                    labelText: 'Nome',
                    maxLength: 100,
                    validator: UsersServices.validateUserName,
                  ),
                  CSTextFormField(
                    controller: _email,
                    labelText: 'Email',
                    hintText: 'nome@dominio.com',
                    maxLength: 100,
                    validator: (email) => _emailErrorText,
                    enabled: false,
                    helperText: 'O email pode ser alterado por módulo específico.',
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CSTextFormField(
                          controller: _cpf,
                          labelText: 'CPF',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],
                          validator: UsersServices.validateCpf,
                        ),
                      ),
                      const Gap(ViewUtils.formsGapSize),
                      Flexible(
                        child: CSDropdownButton(
                          selectedItem: _selectedGender,
                          labelText: 'Gênero (Opcional)',
                          items: Genders.getGendersList(),
                          // validator: UsersServices.validateGender,
                          onChanged: (value) {
                            _selectedGender = value;
                          }
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DateChooserField(
                          labelText: 'Data de nascimento (Opcional)',
                          controller: _birthday,
                          validator: UsersServices.validateBirthday,
                        ),
                      ),
                      const Gap(ViewUtils.formsGapSize),
                      Expanded(
                        child: CSTextFormField(
                          controller: _phone,
                          labelText: 'Telefone (Opcional)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TelefoneInputFormatter(),
                          ],
                          validator: UsersServices.validatePhone,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
        );
      }
    );
  }
}