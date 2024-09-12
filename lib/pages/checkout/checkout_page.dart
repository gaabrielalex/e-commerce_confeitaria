import 'package:confeitaria_divine_cacau/models/address/address_service.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_item.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/cart/cart_page.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/components/cart_page_card.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/delivery/delivery_page.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/payment/payment_page.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  static const double pageSpacing = 32;
  static Widget cartPageDivider = Divider(
    height: 0,
    thickness: 0.5,
    color: CSColors.secondaryV1.color,
    indent: 0,
    endIndent: 0,
  );
  static Widget cartPageDividerWithSpacing(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(
          vertical: CheckoutPage.pageSpacing,
        ),
        child: Responsive.isDesktop(context)
            ? const SizedBox()
            : CheckoutPage.cartPageDivider);
  }

  static Widget summaryTotalCard(
      {required List<CartItem> cartItems, void Function()? onPressed}) {
    return CartPageCard(
      title: 'Resumo',
      content: Column(
        children: [
          cartPageDivider,
          ...{
            'Subtotal': subtotalPrice(cartItems),
            'Frete': 'A calcular',
            'Total': subtotalPrice(cartItems),
          }.entries.map((entry) {
            return [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: CheckoutPage.pageSpacing / 2,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ]),
              ),
              cartPageDivider,
            ];
          }).expand((element) => element),
          Container(
            margin: const EdgeInsets.only(
              top: CheckoutPage.pageSpacing,
            ),
            child: ElevatedButton(
              onPressed: onPressed ?? () {},
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    fontSize: 16,
                  ),
                ),
                fixedSize: WidgetStateProperty.all(
                  const Size.fromHeight(48),
                ),
              ),
              child: const Text('Finalizar compra'),
            ),
          ),
        ],
      ),
    );
  }

  const CheckoutPage({super.key});

  static String subtotalPrice(List<CartItem>? cartItems) =>
      ViewUtils.formatDoubleToCurrency(
          CartService.getSubTotalPrice(cartItems ?? []));

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  final AddressService addressService = AddressService();
  static const double appBarProportion = 32;
  static const Map<String, Widget> tabs = {
    'Carrinho': Icon(Icons.shopping_cart_outlined),
    'Identificação & Entrega': Icon(ViewUtils.defaultUserIcon),
    'Pagamento': Icon(ViewUtils.defaultPaymentIcon),
  };
  late final TabController tabController = TabController(
    length: tabs.length,
    vsync: this,
  );
  Widget? content;

  Widget defaultContainer(
      {required UsersServices usersServices,
      required CartService cartService,
      required Widget Function(UsersServices, CartService) setChild}) {
    cartService.refreshCart(usersServices.currentUsersDocRef);

    if (cartService.cartItems.isEmpty) {
      Future.delayed(const Duration(milliseconds: 3500), () {
        setState(() {
          content = Container(
            margin: const EdgeInsets.only(
              top: 80,
              right: CheckoutPage.pageSpacing,
              left: CheckoutPage.pageSpacing,
            ),
            child: Text(
              'Seu carrinho está vazio!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CSColors.primary.color,
                fontSize: Responsive.isDesktop(context) ? 28 : 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          );
        });
      });
      return content ??
          Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 80),
              child: const CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: 950,
          padding: EdgeInsets.only(
            top: CheckoutPage.pageSpacing *
                (Responsive.isDesktop(context) ? 1.5 : 1),
            bottom: CheckoutPage.pageSpacing * 2,
            right: CheckoutPage.pageSpacing / 2,
            left: CheckoutPage.pageSpacing / 2,
          ),
          child: setChild(usersServices, cartService),
        ),
      ),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   tabController.addListener(() {
  //     // debugPrint('tabController.index: ${tabController.index}');
  //     try {
  //       Provider.of<UsersServices>(context, listen: false)
  //           .prefs!
  //           .setDouble('indexSelectedTab', tabController.index.toDouble());
  //     } catch (e) {
  //       debugPrint(e.toString());
  //     }
  //   });
  // }

  @override
  void didChangeDependencies() {
    ViewUtils.instance.blockNonLoggedUsers(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // try {
    //   int indexSelectedTab = (ModalRoute.of(context)!.settings.arguments
    //       as Map<String, dynamic>)['indexSelectedTab'];
    //   tabController.animateTo(indexSelectedTab);
    // } catch (e) {
    //   try {
    //     tabController.animateTo(
    //         Provider.of<UsersServices>(context, listen: false)
    //             .prefs!
    //             .getDouble('indexSelectedTab')!
    //             .toInt());
    //   } catch (e) {
    //     // debugPrint(e.toString());
    //   }
    // }

    return Consumer<UsersServices>(builder: (context, usersServices, child) {
      return Consumer<CartService>(builder: (context, cartService, child) {
        tabController.addListener(() async {
          var addresses = await addressService.getAllAddresses(usersServices.currentUsersDocRef);
          if (tabController.index == 2 && (cartService.delivery == null || cartService.delivery!.address == null || addresses == null || addresses.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              CSSnackBar(
                  text: 'Selecione um endereço de entrega para continuar.',
                  actionType: CSSnackBarActionType.error),
            );
            tabController.animateTo(1);
          }
        });

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: CSColors.inversePrimary.color,
            toolbarHeight: Responsive.isDesktop(context)
                ? appBarProportion * 3
                : appBarProportion * 0.85 * 3,
            automaticallyImplyLeading: false,
            leading: Responsive.isDesktop(context)
                ? const SizedBox.shrink()
                : IconButton(
                    iconSize: 16,
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
            leadingWidth: Responsive.isDesktop(context) ? 0 : 60,
            titleSpacing: Responsive.isDesktop(context) ? appBarProportion : 0,
            centerTitle: Responsive.isDesktop(context) ? false : true,
            title: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SvgPicture.asset(
                'assets/images/logos/main/main_logo.svg',
                height: Responsive.isDesktop(context)
                    ? appBarProportion
                    : appBarProportion * 0.8,
              ),
            ),
            bottom: TabBar(
              controller: tabController,
              tabs: tabs.entries.map((entry) {
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Responsive.isDesktop(context)
                          ? entry.value
                          : const SizedBox.shrink(),
                      Responsive.isDesktop(context)
                          ? const Gap(10)
                          : const SizedBox.shrink(),
                      Flexible(child: Text(entry.key)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              defaultContainer(
                usersServices: usersServices,
                cartService: cartService,
                setChild: (usersServices, cartService) {
                  return CartPage(
                    usersServices: usersServices,
                    cartService: cartService,
                    tabController: tabController,
                  );
                },
              ),
              defaultContainer(
                usersServices: usersServices,
                cartService: cartService,
                setChild: (usersServices, cartService) {
                  return DeliveryPage(
                    usersServices: usersServices,
                    cartService: cartService,
                    tabController: tabController,
                  );
                },
              ),
              defaultContainer(
                usersServices: usersServices,
                cartService: cartService,
                setChild: (usersServices, cartService) {
                  return PaymentPage(
                    usersServices: usersServices,
                    cartService: cartService,
                  );
                },
              ),
            ],
          ),
        );
      });
    });
  }
}
