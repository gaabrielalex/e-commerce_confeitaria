// ignore_for_file: prefer_final_fields, must_be_immutable

import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_search/widgets/search_page_filter_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_popup_menu_item.dart';
import 'package:confeitaria_divine_cacau/util/widgets/animations/bell_notification.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  Widget? selectedPage;
  SearchPageFilterDrawer? searchPageFilterDrawer;

  MainPage({
    super.key,
    this.selectedPage,
    this.searchPageFilterDrawer,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<FormFieldState> _searchKey = GlobalKey<FormFieldState>();
  final TextEditingController _searchController = TextEditingController();
  late final Widget defaultSearchBar;
  late final Function(String) searchBarOnSubmitted; 
  late double heightAppBar;
  final double deskHeightAppBar = 70;
  final double mobHeightAppBar = 130;
  final double mobileAppBarPadding = 18;
  final double deskIconSize = 24;
  final double mobIconSize = 24;
  Widget addActionsGap() {
    if (Responsive.isDesktop(context)) {
      return const Gap(15);
    } else {
      return const Gap(8);
    }
  }

  List<PopupMenuEntry<int>> defaultPopMenuItems(BuildContext context, UsersServices usersServices) {
    return [
      CSPopupMenuItem.add(
        context: context,
        value: 1,
        text: "Acessar Conta",
        icon: ViewUtils.defaultUserIcon,
        onTap: () {
          Navigator.pushNamed(context, '/account/overview');
        },
      ),
      const PopupMenuDivider(),
      CSPopupMenuItem.add(
        context: context,
        value: 2,
        text: "Meus Pedidos",
        icon: ViewUtils.defaultOrdersIcon,
        onTap: () {
          Navigator.pushNamed(context, '/orders');
        },
      ),
      CSPopupMenuItem.add(
        enabled: false,
        context: context,
        value: 3,
        text: "Favoritos",
        icon: ViewUtils.defaultFavoriteIcon,
      ),
      CSPopupMenuItem.add(
        enabled: false,
        context: context,
        value: 4,
        text: "Ajuda",
        icon: ViewUtils.defaultHelpIcon,
      ),
      const PopupMenuDivider(),
      CSPopupMenuItem.add(
        context: context,
        value: 5,
        text: "Sair",
        icon: ViewUtils.defaultLogoutIcon,
        onTap: () {
          ViewUtils.instance.safeSignOut(context, usersServices.signOut);
        },
      ),
    ];
  }

  List<PopupMenuEntry<int>> adminPopMenuItems(BuildContext context, UsersServices usersServices) {
    List<PopupMenuEntry<int>> items = defaultPopMenuItems(context, usersServices);
    items.removeRange(3, 4);
    return items;
  }

  @override
  void initState() {
    super.initState();
    searchBarOnSubmitted = (String value) {
      if (value.isEmpty) {
        Navigator.pushNamed(context, '/search');
      } else {
        Navigator.pushNamed(context, '/search/$value/${ProductCategories.todos}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}');
      }
    };
    defaultSearchBar = SearchBar(
      key: _searchKey,
      controller: _searchController,
      onSubmitted: searchBarOnSubmitted,
      hintText: 'O que você está buscando?',
      trailing: <Widget>[
        IconButton(
          onPressed: () {
            searchBarOnSubmitted(_searchController.text);
          },
          icon: Icon(
            Icons.search,
            color: CSColors.inversePrimary.color,
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    ViewUtils.instance.blockNonLoggedUsers(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //Definindo a altura da appbar segundo o tamanho da tela
    Responsive.isDesktop(context)
        ? heightAppBar = deskHeightAppBar
        : heightAppBar = mobHeightAppBar;
    widget.searchPageFilterDrawer??= SearchPageFilterDrawer();

    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        bool userIsAdmin = usersServices.currentUsers != null && usersServices.currentUsers!.isAdmin!;
        return Scaffold(
          endDrawer: widget.searchPageFilterDrawer,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(heightAppBar),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.isDesktop(context) ? 25 : mobileAppBarPadding,
              ),
              // color: CSColors.backgroundV1.color,
              child: AppBar(
                toolbarHeight: double.maxFinite,
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,

                /* ------ Leading ------ */
                leading: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: SvgPicture.asset(Responsive.isMobileS(context)
                      ? 'assets/images/logos/main/main_logo_mobile_s.svg'
                      : 'assets/images/logos/main/main_logo.svg'),
                ),
                leadingWidth: Responsive.isDesktop(context)
                    ? 230
                    : Responsive.isMobileS(context)
                        ? 52.2
                        : 175,

                /* ------ Title: Only for desktop !!!!!!!!!!!!!!! ------ */
                centerTitle: true,
                titleSpacing: 35,
                title: Responsive.isDesktop(context)
                    ? SizedBox(
                        height: 50,
                        child: defaultSearchBar,
                      )
                    : null,

                /* ------ Bottom: Only for mobile !!!!!!!!!!!!!!! ------ */
                bottom: Responsive.isMobile(context)
                    ? PreferredSize(
                        preferredSize: Size.zero,
                        child: Container(
                          height: 47 + mobileAppBarPadding,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                            bottom: mobileAppBarPadding,
                          ),
                          child: defaultSearchBar,
                        ),
                      )
                    : null,

                /* ------ Actions ------ */
                actionsIconTheme: IconThemeData(
                  size: Responsive.isDesktop(context) ? deskIconSize : mobIconSize,
                ),
                actions: [
                  userIsAdmin && false
                      // ignore: dead_code
                      ? const SizedBox(width: 55)
                      : const SizedBox.shrink(),
                  IconButton(
                    onPressed: () {},
                    icon: const BellNotification(),
                  ),
                  addActionsGap(),
                  ... userIsAdmin && false
                      // ignore: dead_code
                      ? []
                      : [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/checkout',
                                arguments: {
                                  'indexSelectedTab': 0,
                                }
                              );
                            },
                            icon: const Icon(Icons.shopping_bag_outlined),
                          ),
                          addActionsGap(),
                      ],        
                  PopupMenuButton<int>(
                    tooltip: (() {
                      try {
                        if (usersServices.currentUsers != null) {
                          return usersServices.currentUsers!.userName;
                        } else {
                          return "Usuário";
                        }
                      } catch(e) {
                        return "Usuário";
                      }
                    })(),
                    icon: Icon(Icons.account_circle_rounded,
                        size: Responsive.isDesktop(context)
                            ? deskIconSize * 1.4
                            : mobIconSize * 1.4),
                    itemBuilder: (context) => (userIsAdmin)
                        ? adminPopMenuItems(context, usersServices)
                        : defaultPopMenuItems(context, usersServices),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: widget.selectedPage,
          ),
        );
      }
    );
  }
}
