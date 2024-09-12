// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/linked_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserChangePasswordPage extends StatefulWidget {
  const UserChangePasswordPage({super.key});

  @override
  State<UserChangePasswordPage> createState() => _UserChangePasswordPageState();
}

class _UserChangePasswordPageState extends State<UserChangePasswordPage> {
  static const messageNewPasswordSameSurrentPassword = 'A nova senha não pode ser igual à senha existente.';
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordKey = GlobalKey<FormFieldState>();
  final _newPasswordKey = GlobalKey<FormFieldState>();
  final _confirmNewPasswordKey = GlobalKey<FormFieldState>();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmNewPassword = TextEditingController();
  String? _newPasswordErrorText;
  String? _newPasswordErrorValidation() {
    return (_newPassword.text.isNotEmpty && _newPassword.text == _currentPassword.text)
        ? messageNewPasswordSameSurrentPassword
        : UsersServices.validatePassword(_newPassword.text) ??
            (_newPassword.text != _confirmNewPassword.text
                ? UsersServices.passwordMismatchMessage
                : null);
  }
  bool enableSaveButton = false;
  void Function(String)? onFieldsChanged;

  @override
  void initState() {
    super.initState();  
    onFieldsChanged = (String value) {
      setState(() {
        enableSaveButton = (_currentPassword.text.isNotEmpty && _newPassword.text.isNotEmpty && _confirmNewPassword.text.isNotEmpty) 
          ? true
          : false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return DefaultLayoutUserAccountPages(
          child: DefaultForm(
            formKey: _formKey,
            title: 'Alterar senha',
            onSave:  enableSaveButton
                ? () async {
                  _newPasswordErrorText = _newPasswordErrorValidation();
                  _newPasswordKey.currentState!.validate();
                  if(_newPasswordErrorText != messageNewPasswordSameSurrentPassword) {
                    if(_formKey.currentState!.validate()) {
                      if (await usersServices.changePassword(_newPassword.text)) {
                        _currentPassword.clear();
                        _newPassword.clear();
                        _confirmNewPassword.clear();
                        setState(() {
                          enableSaveButton = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          CSSnackBar(
                            text: 'Senha alterada com sucesso!',
                            actionType: CSSnackBarActionType.success,
                          )
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CSSnackBar(
                            text: ViewUtils.defaultUnexpectedErrorMessage,
                            actionType: CSSnackBarActionType.error,
                          ),
                        );
                      }
                    }
                  } else {
                    String currentPassword = _currentPassword.text;
                    String confirmPassword = _confirmNewPassword.text;
                    _currentPasswordKey.currentState!.reset();
                    _confirmNewPasswordKey.currentState!.reset();
                    _currentPassword.text = currentPassword;
                    _confirmNewPassword.text = confirmPassword;
                  }
                }
                : null,
            onCancel: () => Navigator.pushNamed(context, '/account/overview'),
            contentBuilder: (snapshot) {
              return Wrap(
                runSpacing: ViewUtils.formsGapSize,
                children: [
                  Column(
                    children: [
                      CSTextFormField(
                        textFormFieldKey: _currentPasswordKey,
                        controller: _currentPassword,
                        labelText: 'Senha atual',
                        obscureText: true,
                        iconToggleObscureText: true,
                        disableBottomMarginDefault: true,
                        validator: (value) {
                          if(!UsersServices.passwordMatchesCurrentPassword(context, value!)) {
                            return 'A senha inserida está incorreta.';
                          }
                          return null;
                        },
                        onChanged: onFieldsChanged,
                      ),
                      LinkedText(
                        onTap: () => Navigator.pushNamed(context, '/password-reset'),
                        text: 'Esqueceu sua senha?',
                        margin: const EdgeInsets.only(
                          left: 8,
                          top: 8,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  CSTextFormField(
                    textFormFieldKey: _newPasswordKey,
                    controller: _newPassword,
                    labelText: 'Nova senha',
                    helperText: 'A senha deve ter pelo menos 8 caracteres. Recomendamos incluir pelo menos 1 número e 1 caractere especial.',
                    maxLength: 100,
                    obscureText: true,
                    iconToggleObscureText: true,
                    validator: (newPassword) => _newPasswordErrorText,
                    onChanged: onFieldsChanged,
                  ),
                  CSTextFormField(
                    textFormFieldKey: _confirmNewPasswordKey,
                    controller: _confirmNewPassword,
                    labelText: 'Confirmar nova senha',
                    maxLength: 100,
                    obscureText: true,
                    iconToggleObscureText: true,
                    validator: (confirmPassword) {
                      if (UsersServices.validatePassword(_newPassword.text) == null && confirmPassword != _newPassword.text) {
                        return UsersServices.passwordMismatchMessage;
                      }
                      return null;
                    },
                    onChanged: onFieldsChanged,
                  ),
                ],
              );
            }, 
          ),
        );
      }
    );
  }
}
