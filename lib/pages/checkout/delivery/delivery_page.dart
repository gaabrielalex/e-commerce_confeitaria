// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/address/address.dart';
import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/delivery/delivery.dart';
import 'package:confeitaria_divine_cacau/models/users/users.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/checkout_page.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/components/cart_page_card.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/address_card.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_stream_builder.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/group_radio_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DeliveryPage extends StatefulWidget {
  final UsersServices usersServices;
  final CartService cartService;
  final TabController? tabController;

  const DeliveryPage({
    super.key,
    required this.usersServices,
    required this.cartService,
    this.tabController,
  });

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class ArrayList {}

class _DeliveryPageState extends State<DeliveryPage> {
  final AddressService _addressService = AddressService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _observationController = TextEditingController();
  final TextEditingController _deliveryOptionController =
      TextEditingController();
  final Map<Address, BooleanController> conjunctionAddressSelected = {};
  final List<BooleanController> selectedControllersForAddresses =
      List<BooleanController>.generate(
    10,
    (index) => BooleanController(),
    growable: false,
  );
  late Widget summaryTotalCard;
  late Users? currentUser;
  Widget? streamHasNoDataContent;
  late Widget additionalInformatiosCard;

  Widget dadosPessoaisLine(
      {required IconData icondData, required String text}) {
    return Row(
      children: [
        Icon(icondData, color: Colors.lightBlue),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.tabController!.addListener(() {
      if (widget.tabController!.index == 1 || widget.tabController!.index == 2) {
        _definirDelivery();
      }
    });

    _deliveryOptionController.text = DeliveryCategories.delivery.name;

    summaryTotalCard = CheckoutPage.summaryTotalCard(
      cartItems: widget.cartService.cartItems,
      onPressed: widget.tabController != null
          ? () => widget.tabController!.animateTo(2)
          : null,
    );

    additionalInformatiosCard = CartPageCard(
      title: 'Informações adicionais',
      content: Column(
        children: [
          Form(
            key: _formKey,
            child: Wrap(
              runSpacing: ViewUtils.formsGapSize,
              children: [
                CSTextFormField(
                  controller: _recipientNameController,
                  labelText: 'Nome do destinatário',
                  maxLength: 50,
                ),
                CSTextFormField(
                  controller: _observationController,
                  labelText: 'Observações',
                  maxLength: 200,
                ),
                Column(
                  children: [
                    const ListTile(
                      title: Text('Opção de entrega',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ),
                    GroupRadioListTile(
                      currentOption: _deliveryOptionController.text,
                      options: DeliveryCategories.getNames(),
                      onTaps: [
                        () => _deliveryOptionController.text =
                            DeliveryCategories.delivery.name,
                        () => _deliveryOptionController.text =
                            DeliveryCategories.withDraw.name,
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    currentUser = widget.usersServices.currentUsers;

    for (var controller in selectedControllersForAddresses) {
      controller.onSetValue = (controllerSet, value) {
        // Quando um controller for setado como true, desabilite os outros.
        for (var controller in selectedControllersForAddresses) {
          if (controller.id != controllerSet.id && controller.value) {
            controller.set(false);
          }
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    //Define o endereço de entrega selecionado
    if (widget.cartService.delivery != null &&
        widget.cartService.delivery!.address != null && conjunctionAddressSelected.isNotEmpty) {
      
      Address selectedAddress = widget.cartService.delivery!.address!;
      
      // Encontra o Address correspondente pelo ID
      conjunctionAddressSelected.forEach((address, controller) {
        if (address.id == selectedAddress.id) {
          controller.set(true); // Define como true o BooleanController correspondente
        }
      });
    }

    return Column(
      children: [
        CartPageCard(
          title: 'Dados pessoais',
          textButton: 'Editar',
          onPressedButton: () =>
              Navigator.pushNamed(context, '/account/personal_data'),
          content: Column(
            children: [
              dadosPessoaisLine(
                icondData: Icons.person,
                text: currentUser != null ? currentUser!.userName! : '',
              ),
              const SizedBox(height: 8),
              dadosPessoaisLine(
                icondData: Icons.credit_card,
                text: currentUser != null ? currentUser!.cpf! : '',
              ),
              if (currentUser != null &&
                  currentUser!.phone != null &&
                  currentUser!.phone != '')
                const SizedBox(height: 8),
              if (currentUser != null &&
                  currentUser!.phone != null &&
                  currentUser!.phone != '')
                dadosPessoaisLine(
                  icondData: Icons.phone,
                  text: currentUser!.phone!,
                ),
            ],
          ),
        ),
        CheckoutPage.cartPageDividerWithSpacing(context),
        CartPageCard(
          title: 'Endereço de entrega',
          textButton: 'Adicionar',
          onPressedButton: () =>
              Navigator.pushNamed(context, '/account/addresses/new'),
          content: CsStreamBuilder(
              stream: _addressService.getAllAddressesStream(
                  widget.usersServices.currentUsersDocRef),
              isStream: true,
              streamHasNoDataContent: streamHasNoDataContent,
              streamOnHasNoData: () {
                Future.delayed(const Duration(milliseconds: 2000), () {
                  setState(() {
                    streamHasNoDataContent = Text(
                      'Você ainda não possui endereços cadastrados!',
                      textAlign: TextAlign.center,
                      style: CSTextSyles.alertText(context),
                    );
                  });
                });
              },
              contentBuilder: (snapshots) {
                int i = 0;

                return GridView(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    mainAxisExtent: 230,
                    crossAxisCount: Responsive.isDesktop(context) ? 3 : 1,
                  ),
                  children: [
                    //Adicionando todos os endereços do usuário
                    ...snapshots.data!.docs.map((addressSnapshot) {
                      Address address = Address.fromJson(addressSnapshot);
                      conjunctionAddressSelected[address] =
                          selectedControllersForAddresses[i];
                      i++;

                      return AddressCard(
                          addressIdentification: address.addressIdentification,
                          address: address.address,
                          number: address.number,
                          complement: address.complement,
                          neighborhood: address.neighborhood,
                          city: address.city,
                          stateAcronym: States.stateToAcronym(address.state!),
                          zipCode: address.zipCode,
                          isSelectable: true,
                          onSelectedController: conjunctionAddressSelected[address],
                          onSelected: (value) {
                            if (value) {
                              _definirDelivery();
                            }
                          },
                          onEdit: () => Navigator.pushNamed(
                              context, '/account/addresses/edit/${address.id}'),
                          onConfirmDelete: () async {
                            if (await _addressService
                                .deleteAddress(address.id!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                CSSnackBar(
                                  text: 'Endereço excluído com sucesso!',
                                  actionType: CSSnackBarActionType.success,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                CSSnackBar(
                                  text:
                                      'Erro ao excluir endereço! Tente novamente mais tarde.',
                                  actionType: CSSnackBarActionType.error,
                                ),
                              );
                            }
                          });
                    }).toList(),
                  ],
                );
              }),
        ),
        CheckoutPage.cartPageDividerWithSpacing(context),
        Responsive.isDesktop(context)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: additionalInformatiosCard),
                  const Gap(CheckoutPage.pageSpacing * 2),
                  Flexible(
                    child: summaryTotalCard,
                  ),
                ],
              )
            : Column(
                children: [
                  additionalInformatiosCard,
                  CheckoutPage.cartPageDividerWithSpacing(context),
                  summaryTotalCard
                ],
              ),
      ],
    );
  }

  void _definirDelivery() {
    var devilvery = Delivery(
      addressRef: getSelectedAddress()!.addressRef!,
      address: getSelectedAddress(),
      deliveryCategory: DeliveryCategories.values.firstWhere(
          (element) => element.name == _deliveryOptionController.text),
      recipientNanme: _recipientNameController.text,
      observations: _observationController.text,
    );

    widget.cartService.delivery = devilvery;
  }

  Address? getSelectedAddress() {
    try {
      // Busca o primeiro endereço onde o valor do BooleanController é true
      return conjunctionAddressSelected.entries
          .firstWhere((entry) => entry.value.value)
          .key;
    } catch (e) {
      // Caso não exista nenhum endereço com valor true, retorna null
      return null;
    }
  }
}
