import 'package:confeitaria_divine_cacau/models/users/service/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/cart/cart_page.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    tabController.addListener(() {
      // debugPrint('tabController.index: ${tabController.index}');
      try {
        Provider.of<UsersServices>(context, listen: false).prefs!.setDouble('indexSelectedTab', tabController.index.toDouble());
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  @override
  void didChangeDependencies() {
    ViewUtils.instance.blockNonLoggedUsers(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    try {
      int indexSelectedTab = (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['indexSelectedTab'];
      tabController.animateTo(indexSelectedTab);
    } catch (e) {
      try {
        tabController.animateTo(Provider.of<UsersServices>(context, listen: false).prefs!.getDouble('indexSelectedTab')!.toInt());
      } catch (e) {
        // debugPrint(e.toString());
      }
    }

    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
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
                '/images/logos/main/main_logo.svg',
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
              const CartPage(),
              Container(),
              Container(),
            ],
          ),
        );
      }
    );
  }
}
