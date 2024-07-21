// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/models/product/product_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_search/widgets/search_page_filter_drawer.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/product_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

class ProductSearchPage extends StatefulWidget {
  String query;
  final ProductCategories category;
  final TypesChocolate typesChocolate;
  RangeValues currentPriceRange;

  ProductSearchPage({
    super.key,
    this.query = '',
    this.category = ProductCategories.todos,
    this.typesChocolate = TypesChocolate.todos,
    this.currentPriceRange = const RangeValues(SearchPageFilterDrawer.minPrice, SearchPageFilterDrawer.maxPrice),
  });

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final ProductService _productService = ProductService();
  Widget? streamHasNoDataContent;

  @override
  void initState() {
    super.initState();
    widget.query = widget.query.isEmpty ? ViewUtils.allProductQuery : widget.query;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        bool userIsAdmin = usersServices.currentUsers != null && usersServices.currentUsers!.isAdmin!;
        
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: Responsive.isDesktop(context)
                    ? 45
                    : ViewUtils.defaultMobileContentHorizontalPadding,
                horizontal: Responsive.isDesktop(context)
                    ? ViewUtils.defaultDesktopContentHorizontalPadding
                    : ViewUtils.defaultMobileContentHorizontalPadding),
            width: 1220,
            child: StreamBuilder<QuerySnapshot>(
              stream: !userIsAdmin
                  ? _productService.getAllProductsStream(
                      widget.category != ProductCategories.todos ? widget.category.text : null,
                      widget.typesChocolate != TypesChocolate.todos ? widget.typesChocolate.text : null,
                      widget.currentPriceRange.start,
                      widget.currentPriceRange.end,
                    )
                  /* Produtos que não estão disponíveis para venda são exibidos apenas para o administrador, assim
                  como outras há outras restrições de exibição de produtos para o usuário comum, que, no caso 
                  dessa consulta, são ignoradas para que o administrador possa visualizar todos os produtos */
                  : _productService.getAllProductsStreamWhitoutRestrictions(
                      widget.category != ProductCategories.todos ? widget.category.text : null,
                      widget.typesChocolate != TypesChocolate.todos ? widget.typesChocolate.text : null,
                  ),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
                if(snapshots.hasError) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Text('Erro ao carregar os dados! Caso o erro persista, entre em contato com o suporte.',
                        textAlign: TextAlign.center,
                        style: CSTextSyles.alertText(context),
                      ),
                    ),
                  );
                } else if(!snapshots.hasData || snapshots.data == null || snapshots.data!.docs.isEmpty) {
                  Future.delayed(const Duration(milliseconds: 3000), () {
                    setState(() {
                      streamHasNoDataContent = Container(
                        margin: const EdgeInsets.only(top: 64),
                        child: Text('Não encontramos nenhum resultado para a pesquisa "${widget.query}" feita. Realize uma nova busca ou tente modificando os filtros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CSColors.primary.color,
                            fontSize: Responsive.isDesktop(context) ? 20 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    });
                  });
                  return streamHasNoDataContent 
                      ?? Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const CircularProgressIndicator()
                        ),
                      );
                } else {
                  //Converte o QuerySnapshot em uma lista de produtos
                  List<Product> products = <Product>[];
                  products = snapshots.data!.docs.map(
                    (productSnapshot) {
                      return Product.fromJson(productSnapshot);
                    }
                  ).toList();
                  //O firebase não suporte esse tipo de filtro, logo, é feito diretamente no código
                  if (widget.query.toLowerCase() != ViewUtils.allProductQuery.toLowerCase()) {
                    products = _productService.filterByDescription(products, widget.query);
                  }
                  if(products.isEmpty) {
                    Future.delayed(const Duration(milliseconds: 3000), () {
                      setState(() {
                        streamHasNoDataContent = Container(
                          margin: const EdgeInsets.only(top: 64),
                          child: Text('Não encontramos nenhum resultado para a pesquisa "${widget.query}" feita. Realize uma nova busca ou tente modificando os filtros.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CSColors.primary.color,
                              fontSize: Responsive.isDesktop(context) ? 20 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      });
                    });
                    return streamHasNoDataContent 
                        ?? Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: const CircularProgressIndicator()
                          ),
                        ); 
                  }
                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          bottom: Responsive.isDesktop(context) ? 40 : 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: Responsive.isDesktop(context)
                              ? CrossAxisAlignment.baseline
                              : CrossAxisAlignment.center,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: CSColors.primary.color,
                                    fontSize: Responsive.isDesktop(context) ? 30 : 26,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      // ignore: unnecessary_null_comparison
                                      text: widget.query == null || widget.query.isEmpty 
                                        || widget.query.toLowerCase() == ViewUtils.allProductQuery.toLowerCase()
                                          ? 'Todos os produtos'
                                          : widget.query[0].toUpperCase() + widget.query.substring(1),
                                    ),
                                    TextSpan(
                                      text: '\t\t(${products.length})',
                                      style: TextStyle(
                                        color: CSColors.secondaryV1.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w100,
                                      )
                                    ),
                                  ]
                                ),
                              ),
                            ),
                            Responsive.isDesktop(context)
                                ? SizedBox(
                                    width: 110,
                                    child: TextButton(
                                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                                        style: const ButtonStyle(
                                          minimumSize: WidgetStatePropertyAll(Size.fromHeight(45)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text('Filtrar',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                )),
                                            Gap(5),
                                            Icon(
                                              ViewUtils.defaultFilterIcon,
                                              size: 20,
                                            ),
                                          ],
                                        )),
                                  )
                                : IconButton(
                                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                                    iconSize: 26,
                                    icon: const Icon(
                                      ViewUtils.defaultFilterIcon,
                                    ),
                                  )
                          ],
                        ),
                      ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double desktopMainAxisSpacing = 64;
                        double desktopCrossAxisSpacing = 16;
                        double mobileMainAxisSpacing = desktopMainAxisSpacing / 2;
                        double mobileCrossAxisSpacing = desktopCrossAxisSpacing / 1.15;
                        double mobileCrossAxisSpacingBelow630 = desktopCrossAxisSpacing / 1.70;
                        return GridView(
                            shrinkWrap: true,
                            primary: false,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: MediaQuery.of(context).size.width > ProductCard.adaptivePoint1000 ? desktopMainAxisSpacing : mobileMainAxisSpacing,
                              crossAxisSpacing: MediaQuery.of(context).size.width > ProductCard.adaptivePoint1000 
                                  ? desktopCrossAxisSpacing
                                  : MediaQuery.of(context).size.width > ProductCard.adaptivePoint630
                                      ? mobileCrossAxisSpacing
                                      : mobileCrossAxisSpacingBelow630,
                              mainAxisExtent: MediaQuery.of(context).size.width > ProductCard.adaptivePoint1000
                                      ? ((constraints.maxWidth - 2 * desktopCrossAxisSpacing) / 3) + ProductCard.legendHeight1000
                                      : MediaQuery.of(context).size.width > ProductCard.adaptivePoint630
                                          ? ((constraints.maxWidth - mobileCrossAxisSpacing) / 2) + ProductCard.legendHeight630
                                          : MediaQuery.of(context).size.width > ProductCard.adaptivePoint375
                                              ? ((constraints.maxWidth - mobileCrossAxisSpacingBelow630) / 2) + ProductCard.legendHeight375
                                                  : MediaQuery.of(context).size.width > ProductCard.adaptivePoint310
                                                      ? ((constraints.maxWidth - mobileCrossAxisSpacingBelow630) / 2) + ProductCard.legendHeight310
                                                      : ((constraints.maxWidth - mobileCrossAxisSpacingBelow630) / 2) + ProductCard.legendHeighBelow310,
                              crossAxisCount: MediaQuery.of(context).size.width > ProductCard.adaptivePoint1000
                                  ? 3
                                  : 2
                            ),
                            children: [
                              //Adicionando os produtos
                              ...products.map(
                                (product) {
                                  return ProductCard(
                                    isDeleted: product.deleted ?? false,
                                    imageUrl: product.imageUrl,
                                    description: product.description,
                                    category: product.category,
                                    unitPrice: product.unitPrice, 
                                    displayEditButtons: userIsAdmin,
                                    onCardTap: () => Navigator.pushNamed(context, '/product/detail/${product.id}'),
                                    onEditPressed: () => Navigator.pushNamed(context, '/product/edit/${product.id}'),
                                    onConfirmDisable: () async {
                                      if (await _productService.disableProduct(product.id!, true)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Produto desativado com sucesso!',
                                            actionType: CSSnackBarActionType.success,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Erro ao desativar o produto! Tente novamente mais tarde.',
                                            actionType: CSSnackBarActionType.error,
                                          ),
                                        );
                                      }
                                    },
                                    onConfirmEnable: () async {
                                      if (await _productService.disableProduct(product.id!, false)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Produto ativado com sucesso!',
                                            actionType: CSSnackBarActionType.success,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          CSSnackBar(
                                            text: 'Erro ao ativar o produto! Tente novamente mais tarde.',
                                            actionType: CSSnackBarActionType.error,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }
                              ),
                            ],
                          );
                      }
                    ),
                    ],
                  );
                }
              }
            ),
          ),
        );
      }
    );
  }
}
