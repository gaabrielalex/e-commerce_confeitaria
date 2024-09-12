import 'package:confeitaria_divine_cacau/models/users/users_service.dart'; 
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_outline_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/linked_text.dart';
import 'package:confeitaria_divine_cacau/util/widgets/layouts/flexible_line.dart';
import 'package:provider/provider.dart';

class LoginPageContent extends StatefulWidget {
  static const double width = 335;
  static const double height = width * 1.80;

  const LoginPageContent({super.key});

  @override
  State<LoginPageContent> createState() => _LoginPageContentState();
}

class _LoginPageContentState extends State<LoginPageContent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final double _gapSize = 16;

  @override
  void didChangeDependencies() {
    ViewUtils.instance.redirectLoggedUsersToHome(context: context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return SizedBox(
          height: LoginPageContent.height,
          width: LoginPageContent.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset('assets/images/logos/main/main_logo.svg', width: LoginPageContent.width),
              Text(
                'Bem-Vindo de Volta!',
                textAlign: TextAlign.center,
                style: CSTextSyles.decoratedTitle(context),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CSTextFormField(
                      controller: _email, 
                      labelText: 'Email',
                      validator: (email) {
                        if(email == null || email.isEmpty) {
                          return 'Insira seu endereço de e-mail para continuar.';
                        }
                        return null;      
                      }
                    ),
                    Gap(_gapSize),
                    CSTextFormField(
                      controller: _password,
                      labelText: 'Senha',
                      obscureText: true,
                      iconToggleObscureText: true,
                      disableBottomMarginDefault: true,
                      validator: (password) {
                        if(password == null || password.isEmpty) {
                          return 'Por favor, insira sua senha.';
                        }
                        return null;      
                      }
                    ),
                    LinkedText(
                      onTap: () => Navigator.pushNamed(context, '/password-reset'),
                      text: 'Esqueceu sua senha?',
                      margin: const EdgeInsets.only(top: 8),
                      alignment: Alignment.centerRight,
                    ),
                    Gap(2 * _gapSize),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()){
                          if(await usersServices.signIn(_email.text, _password.text)) {
                            ViewUtils.instance.safeSignIn(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CSSnackBar(
                                text: 'Email ou senha incorretos.',
                                actionType: CSSnackBarActionType.error,
                              ),
                            );
                          }
                        } 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CSColors.primarySwatchV2.color,
                      ),
                      child: const Text('Entrar'),
                    ),
                    Gap(_gapSize),
                    Row(
                      children: [
                        FlexibleLine(),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12
                          ),
                          child: Text(
                            "ou",
                            textAlign: TextAlign.center,
                            style: CSTextSyles.decoratedMediumText(),
                          )
                        ),
                        FlexibleLine(),
                      ],
                    ),
                    Gap(_gapSize),
                    const CSOutlineButton(
                      text: 'Login com o Google',
                      iconPath: 'assets/images/icons/google.png',
                    ),
                    Gap(2 * _gapSize),
                    LinkedText(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      text: 'Não tem uma conta? Inscreva-se aqui',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}