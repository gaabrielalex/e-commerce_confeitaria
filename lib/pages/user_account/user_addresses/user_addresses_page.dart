// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/address_card.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserAddressesPage extends StatefulWidget {
  const UserAddressesPage({super.key});

  @override
  State<UserAddressesPage> createState() => _UserAddressesPageState();
}

class _UserAddressesPageState extends State<UserAddressesPage> {
  final AddressService _addressService = AddressService();
  Widget? streamHasNoDataContent;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {    
        return DefaultLayoutUserAccountPages(
          child: DefaultForm(
            onAddition: () async {
              if(await _addressService.hasReachedAddressesLimit(usersServices.currentUsersDocRef)) {
                ViewUtils.hasReachedAddressesLimitScaffoldMessenger(context);
              } else {
                Navigator.pushNamed(context, '/account/addresses/new');
              }
            },
            title: 'Endereços',
            isListing: true,
            isStream: true,
            stream: _addressService.getAllAddressesStream(usersServices.currentUsersDocRef),
            streamHasNoDataContent: streamHasNoDataContent,
            streamOnHasNoData: () {
              Future.delayed(const Duration(milliseconds: 2000), () {
                setState(() {
                  streamHasNoDataContent = Text('Você ainda não possui endereços cadastrados!',
                    textAlign: TextAlign.center,
                    style: CSTextSyles.alertText(context),
                  );
                });
              });
            },
            contentBuilder: (snapshots) {
              return GridView(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  mainAxisExtent: 220,
                  crossAxisCount: Responsive.isDesktop(context) ? 2 : 1,
                ),
                children: [
                  //Adicionando todos os endereços do usuário
                  ...snapshots.data!.docs.map(
                    (addressSnapshot) {
                      Address address = Address.fromJson(addressSnapshot);
                      return AddressCard(
                        addressIdentification: address.addressIdentification,
                        address: address.address,
                        number: address.number,
                        complement: address.complement,
                        neighborhood: address.neighborhood,
                        city: address.city,
                        stateAcronym: States.stateToAcronym(address.state!),
                        zipCode: address.zipCode,
                        onEdit: () => Navigator.pushNamed(context, '/account/addresses/edit/${address.id}'),
                        onConfirmDelete: () async {
                          if(await _addressService.deleteAddress(address.id!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CSSnackBar(
                                text: 'Endereço excluído com sucesso!',
                                actionType: CSSnackBarActionType.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CSSnackBar(
                                text: 'Erro ao excluir endereço! Tente novamente mais tarde.',
                                actionType: CSSnackBarActionType.error,
                              ),
                            );
                          }
                        } 
                      );
                    }
                  ).toList(),
                ],
              );
            } 
          ),
        );
      }
    );
  }
}
