// ignore_for_file: use_build_context_synchronously

import 'package:brasil_fields/brasil_fields.dart';
import 'package:confeitaria_divine_cacau/models/users/users.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_dropdown_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/date_chooser_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/layouts/simple_page_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/linked_text.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  static const double formsGapSize = 16;

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _cpf = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  String? _selectedGender;
  String? _emailErrorText;

  @override
  void didChangeDependencies() {
    ViewUtils.instance.redirectLoggedUsersToHome(
      context: context,
      message: 'Para criar uma nova conta, primeiro faça logout da conta atual.',
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return SimplePageStructure(
          child: SizedBox(
            width: 420,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Criar sua conta',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: Responsive.isDesktop(context) ? 45 : 37,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(2 * SignUpPage.formsGapSize),
                Form(
                  key: _formKey,
                  child: Wrap(
                    runSpacing: SignUpPage.formsGapSize,
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
                      ),
                      CSTextFormField(
                        controller: _password,
                        labelText: 'Senha',
                        helperText: 'A senha deve ter pelo menos 8 caracteres. Recomendamos incluir pelo menos 1 número e 1 caractere especial.',
                        maxLength: 100,
                        obscureText: true,
                        iconToggleObscureText: true,
                        validator: (password) {
                          return UsersServices.validatePassword(password) ??
                              (password != _confirmPassword.text
                                  ? UsersServices.passwordMismatchMessage
                                  : null);
                        }
                      ),
                      CSTextFormField(
                        controller: _confirmPassword,
                        labelText: 'Confirmar senha',
                        maxLength: 100,
                        obscureText: true,
                        iconToggleObscureText: true,
                        validator: (confirmPassword) {
                          if (UsersServices.validatePassword(_password.text) == null && confirmPassword != _password.text) {
                            return UsersServices.passwordMismatchMessage;
                          }
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
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
                          const Gap(SignUpPage.formsGapSize),
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
                          const Gap(SignUpPage.formsGapSize),
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
                  ),
                ),
                const Gap(2.5 * SignUpPage.formsGapSize),
                ElevatedButton(
                  onPressed: () async {
                    _emailErrorText = await usersServices.validateEmail(_email.text);
                    bool dataIsValid = _formKey.currentState!.validate();
                    
                    if(dataIsValid) {
                      if( await usersServices.signUp(
                          _userName.text,
                          _email.text,
                          _password.text,
                          _cpf.text,
                          _selectedGender,
                          _birthday.text.isNotEmpty
                              ? DateFormat("dd/MM/yyyy").parse(_birthday.text)
                              : null,
                          _phone.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CSSnackBar(
                            text: 'Conta criada com sucesso!',
                            actionType: CSSnackBarActionType.success,
                          ),
                        );
                        ViewUtils.instance.safeSignIn(context);

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CSSnackBar(
                            text: ViewUtils.defaultUnexpectedErrorMessage,
                            actionType: CSSnackBarActionType.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Inscrever-se'),
                ),
                const Gap(2 * SignUpPage.formsGapSize),
                LinkedText(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  text: 'Já tem uma conta? Faça login aqui.',
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
