// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/loading/loading_page.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/group_menu/group_menu.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/group_menu/group_menu_list_tile.dart';
import 'package:provider/provider.dart';

class AccountOverviewPage extends StatelessWidget {
  const AccountOverviewPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        bool userIsAdmin = usersServices.currentUsers != null && usersServices.currentUsers!.isAdmin!;

        return Center(
          child: Container(
            width: ViewUtils.defaultContentWidth,
            padding: const EdgeInsets.symmetric( 
              vertical: 45,
              horizontal: ViewUtils.defaultMobileContentHorizontalPadding,
            ),
            child: Wrap(
              runSpacing: 24,
              children: [
                GroupMenu(
                  title: 'Conta',
                  tiles: [
                    GroupMenuListTile(
                      onTap: () => Navigator.pushNamed(context, '/account/personal_data'),
                      leadingIcon: ViewUtils.defaultUserIcon,
                      titleText: 'Dados pessoais',
                    ),
                    ... userIsAdmin && false
                        // ignore: dead_code
                        ? []
                        : [
                            GroupMenuListTile(
                              onTap: () => Navigator.pushNamed(context, '/account/addresses'),
                              leadingIcon: Icons.map_outlined,
                              titleText: 'Endereços',
                            ),
                            GroupMenuListTile(
                              onTap: null,
                              enabled: false,
                              leadingIcon: ViewUtils.defaultPaymentIcon,
                              titleText: 'Cartões',
                            ),
                            // GroupMenuListTile(
                            //   onTap: null,
                            //   leadingIcon: Icons.star_border_outlined,
                            //   titleText: 'Fidelidade',
                            // ),
                        ],
                  ],  
                ),
                userIsAdmin
                    ? GroupMenu(
                        title: 'Administração',
                        tiles: [
                          GroupMenuListTile(
                            onTap: () => Navigator.pushNamed(context, '/product/new'),
                            leadingIcon: ViewUtils.defaultOrdersIcon,
                            titleText: 'Cadastrar Produto',
                          ),
                        ],
                      ) 
                    : const SizedBox.shrink(),
                userIsAdmin && false
                    // ignore: dead_code
                    ? const SizedBox.shrink()
                    : GroupMenu(
                        title: 'Compras',
                        tiles: [
                          GroupMenuListTile(
                            onTap: () => Navigator.pushNamed(context, '/orders'),
                            leadingIcon: ViewUtils.defaultOrdersIcon,
                            titleText: 'Pedidos',
                          ),
                          GroupMenuListTile(
                            onTap: null,
                            enabled: false,
                            leadingIcon: ViewUtils.defaultFavoriteIcon,
                            titleText: 'Favoritos',
                          ),
                        ],
                      ),
                GroupMenu(
                  title: 'Segurança e privacidade',
                  tiles: [
                    GroupMenuListTile(
                      onTap: () => Navigator.pushNamed(context, '/password-reset'),
                      leadingIcon: Icons.lock_outline,
                      titleText: 'Alterar Senha',
                    ),
                    // GroupMenuListTile(
                    //   onTap: null,
                    //   leadingIcon: Icons.format_list_bulleted_outlined,
                    //   titleText: 'Métodos de login',
                    // ),
                    GroupMenuListTile(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Excluir conta'),
                            content: const Text('Tem certeza que deseja excluir sua conta?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoadingPage(
                                      condition: () async {
                                        return await usersServices.deleteUser();
                                      },
                                      onSucess: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Sua conta foi excluída com sucesso!',
                                            actionType: CSSnackBarActionType.success,
                                          ),
                                        );
                                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                                      },
                                      onFail: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Houve um erro ao excluir sua conta, tente novamente mais tarde.',
                                            actionType: CSSnackBarActionType.error,
                                          ),
                                        );
                                        Navigator.pushNamedAndRemoveUntil(context, '/account/overview', (route) => false);
                                      },
                                    )),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Excluir'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        );
                      },
                      leadingIcon: ViewUtils.defaultDeleteIcon,
                      titleText: 'Excluir conta',
                    ),
                  ], 
                ),
                GroupMenu(
                  title: 'Configurações',
                  tiles: [
                    GroupMenuListTile(
                      onTap: null,
                      enabled: false,
                      leadingIcon: ViewUtils.defaultNotificationsIcon,
                      titleText: 'Notificações',
                    ),
                    GroupMenuListTile(
                      onTap: null,
                      enabled: false,
                      leadingIcon: ViewUtils.defaultHelpIcon,
                      titleText: 'Ajuda',
                    ),
                    GroupMenuListTile(
                      onTap: () {
                        ViewUtils.instance.safeSignOut(context, usersServices.signOut);
                      },
                      leadingIcon: ViewUtils.defaultLogoutIcon,
                      titleText: 'Sair',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
