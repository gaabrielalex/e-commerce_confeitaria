import 'package:confeitaria_divine_cacau/models/address/address_service.dart';  
import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/pages/authentication/signup/signup_page.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/checkout_page.dart';
import 'package:confeitaria_divine_cacau/pages/orders/orders_page.dart';
import 'package:confeitaria_divine_cacau/pages/password_reset/password_reset_page.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_detail/product_detail_page.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_forms/product_edit_page.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_forms/product_registration_page.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_search/product_search_page.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_search/widgets/search_page_filter_drawer.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_addresses/address_forms/address_edit_page.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_addresses/address_forms/address_registration_page.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_addresses/user_addresses_page.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_change_password/user_change_password_page.dart';
import 'package:confeitaria_divine_cacau/util/configs/configs.dart';
import 'package:confeitaria_divine_cacau/util/picked_image/picked_image_service.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:confeitaria_divine_cacau/pages/authentication/login/login_page.dart';
import 'package:confeitaria_divine_cacau/pages/home/home_page.dart';
import 'package:confeitaria_divine_cacau/pages/main/main_page.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/account_overview/account_overview_page.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/user_personal_data/user_personal_data_page.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_dark_theme.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:regex_router/regex_router.dart';

void main() async {
  await Hive.initFlutter();

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
      options: Configs.firebaseConfig,
    );
  }
  else {    
    await Firebase.initializeApp(
      options: Configs.firebaseConfig,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = RegexRouter.create({
      "/account/addresses/edit/:id": (context, args) => 
          MainPage(selectedPage: AddressEditPage(addressId: args["id"])),
      "/product/edit/:id": (context, args) =>
          MainPage(selectedPage: ProductEditPage(productId: args["id"])),
    "/product/detail/:id": (context, args) => 
          MainPage(selectedPage: ProductDetailPage(productId: args["id"])),
      "/search/:query/:category/:typesChocolate/:minPrice/:maxPrice": (context, args) => 
          MainPage(
            selectedPage: ProductSearchPage(
              query: args["query"] ?? ViewUtils.allProductQuery,
              category: args["category"] == null 
                  ? ProductCategories.todos 
                  : ProductCategories.values.firstWhere((element) => element.toString() == args["category"]),
              typesChocolate: args["typesChocolate"] == null
                  ? TypesChocolate.todos 
                  : TypesChocolate.values.firstWhere((element) => element.toString() == args["typesChocolate"]),
              currentPriceRange: RangeValues(
                double.tryParse(args["minPrice"] ?? SearchPageFilterDrawer.minPrice.toString()) ?? SearchPageFilterDrawer.minPrice,
                double.tryParse(args["maxPrice"] ?? SearchPageFilterDrawer.maxPrice.toString()) ?? SearchPageFilterDrawer.maxPrice,
              )
            ),
            searchPageFilterDrawer: SearchPageFilterDrawer(
              query: args["query"] ?? ViewUtils.allProductQuery,
              category: args["category"] == null 
                  ? ProductCategories.todos 
                  : ProductCategories.values.firstWhere((element) => element.toString() == args["category"]),
              typesChocolate: args["typesChocolate"] == null
                  ? TypesChocolate.todos 
                  : TypesChocolate.values.firstWhere((element) => element.toString() == args["typesChocolate"]),
              currentPriceRange: RangeValues(
                double.tryParse(args["minPrice"] ?? SearchPageFilterDrawer.minPrice.toString()) ?? SearchPageFilterDrawer.minPrice,
                double.tryParse(args["maxPrice"] ?? SearchPageFilterDrawer.maxPrice.toString()) ?? SearchPageFilterDrawer.maxPrice,
              )
            ),
          ),
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UsersServices(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => AddressService(),
          lazy: false,
        ),
        ChangeNotifierProvider<PickedImageService>(
          create: (context) => PickedImageService(),
          lazy: false,
        ),
        ChangeNotifierProvider<CartService>(
          // create: (context) => CartService(Provider.of<UsersServices>(context, listen: false).currentUsersDocRef),
          create: (context) => CartService(null),
          lazy: false,
        )
      ],
      child: MaterialApp(
        title: 'Divine Cacau',
        debugShowCheckedModeBanner: false,
        theme: CSDarkTheme.themeData(context),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en'),
          Locale('es'),
        ],
        onGenerateRoute: router.generateRoute,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/password-reset': (context) => const PasswordResetPage(),
          '/home':(context) => MainPage(selectedPage: const HomePage()),
          '/account/overview': (context) => MainPage(selectedPage: const AccountOverviewPage()),
          '/account/personal_data': (context) => MainPage(selectedPage: const UserPersonalDataPage()),
          '/account/addresses': (context) => MainPage(selectedPage: const UserAddressesPage()),
          '/account/change_password':  (context) => MainPage(selectedPage: const UserChangePasswordPage()),
          '/account/addresses/new': (context) => MainPage(selectedPage: const AddressRegistrationPage()),
          '/orders': (context) => MainPage(selectedPage: const OrdersPage()),
          '/search': (context) => MainPage(selectedPage: ProductSearchPage()),
          '/checkout': (context) => const CheckoutPage(),
          '/product/new': (context) => MainPage(selectedPage: const ProductRegistrationPage()),
        },
      ),
    );
  }
}