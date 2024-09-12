// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/layouts/simple_page_structure.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return SimplePageStructure(
          child: SizedBox(
            width: 450,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Redefinição de senha',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width >= 1000
                          ? 48
                          : Responsive.isDesktop(context)
                              ? 40
                              : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Gap(
                  MediaQuery.of(context).size.width >= 1000 
                      ? 32.160
                      : Responsive.isDesktop(context)
                          ? 26.800
                          : 21.440,
                ),
                Text(
                  'Insira seu endereço de e‑mail que você usou para se registrar.'
                  ' Vamos enviar um e‑mail com um link para você redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CSColors.secondaryV1.color,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const Gap(ViewUtils.formsGapSize),
                Form(
                  key: _formKey,
                  child: Wrap(
                    runSpacing: ViewUtils.formsGapSize,
                    alignment: WrapAlignment.center,
                    children: [
                      CSTextFormField(
                        controller: _email,
                        labelText: 'Email',
                        validator: (email) => _emailErrorText,
                      ),
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          child: const Text('Enviar'),
                          onPressed: () async {
                            _emailErrorText = await usersServices.validateEmail(
                              _email.text,
                              disregardExistingEmail: true,
                            ) ?? (await UsersServices.emailAlreadyExists(_email.text) 
                                    ? null
                                    : 'Este endereço não está vinculado a nenhuma conta.');
                            _formKey.currentState!.validate();

                            if(_emailErrorText == null) {
                              if(await usersServices.sendPasswordResetEmail(_email.text)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CSSnackBar(
                                    text: 'Enviamos um e‑mail para você. Siga as instruções para redefinir sua senha.',
                                    actionType: CSSnackBarActionType.success,
                                  ),
                                );
                                _email.clear();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CSSnackBar(
                                    text: 'Erro ao enviar e-mail. Caso o problema persista, entre em contato conosco.',
                                    actionType: CSSnackBarActionType.error,
                                  ),
                                );
                              }
                            }
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
