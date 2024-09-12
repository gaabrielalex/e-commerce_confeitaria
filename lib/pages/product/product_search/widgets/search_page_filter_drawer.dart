// ignore_for_file: must_be_immutable

import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_dark_theme.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/group_radio_list_tile.dart';
import 'package:flutter/material.dart';

class SearchPageFilterDrawer extends StatefulWidget {
  static const double minPrice = 20;
  static const double maxPrice = 2000;
  String query;
  final ProductCategories category;
  final TypesChocolate typesChocolate;
  RangeValues currentPriceRange;

  SearchPageFilterDrawer({
    super.key,
    this.query = '',
    this.category = ProductCategories.todos,
    this.typesChocolate = TypesChocolate.todos,
    this.currentPriceRange = const RangeValues(minPrice, maxPrice),
  });

  @override
  State<SearchPageFilterDrawer> createState() => _SearchPageFilterDrawerState();
}

class _SearchPageFilterDrawerState extends State<SearchPageFilterDrawer> {
  static const double widthFactor = 0.3;
  static const double minWidth = 280;

  //Expansion Panels Settings
  List<bool> expansionPanelsIsOpen = [false, false, false];
  ExpansionPanel filterDrawerExpansionPanel({required bool isExpanded, required String title, required Widget body}) {
    return ExpansionPanel(
      isExpanded: isExpanded,
      backgroundColor: CSDarkTheme.themeData(context).drawerTheme.backgroundColor,
      headerBuilder: (context, isOpen) {
        return ListTile(
          title: Text(title,
              style: const TextStyle(
                fontSize: 16,
              )),
        );
      },
      body: body,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.query = widget.query.isEmpty ? ViewUtils.allProductQuery : widget.query;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.currentPriceRange.start > widget.currentPriceRange.end) {
      widget.currentPriceRange = RangeValues(widget.currentPriceRange.end, widget.currentPriceRange.start);
    }
    if(widget.currentPriceRange.start < SearchPageFilterDrawer.minPrice) {
      widget.currentPriceRange = RangeValues(SearchPageFilterDrawer.minPrice, widget.currentPriceRange.end);
    }
    if(widget.currentPriceRange.end > SearchPageFilterDrawer.maxPrice) {
      widget.currentPriceRange = RangeValues(widget.currentPriceRange.start, SearchPageFilterDrawer.maxPrice);
    }
    return Container(
      margin: const EdgeInsets.only(left: 45),
      child: Drawer(
        width: MediaQuery.of(context).size.width * widthFactor > minWidth
            ? MediaQuery.of(context).size.width * widthFactor
            : minWidth,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 50),
          children: [
            ListTile(
              title: Text('Filtros',
                  style: TextStyle(
                    fontSize: Responsive.isDesktop(context) ? 30 : 24,
                    fontWeight: FontWeight.w600,
                  )),
              trailing: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                iconSize: 16,
                icon: const Icon(Icons.close_outlined),
              ),
              contentPadding: const EdgeInsets.only(
                right: 12,
                left: 15,
                top: 10,
                bottom: 10,
              ),
            ),
            ExpansionPanelList(
              dividerColor: CSColors.secondaryV1.color,
              expansionCallback: (i, isOpen) {
                setState(() {
                  expansionPanelsIsOpen[i] = isOpen;
                });
              },
              children: [
                filterDrawerExpansionPanel(
                  isExpanded: expansionPanelsIsOpen[0],
                  title: 'Categoria',
                  body: GroupRadioListTile(
                    currentOption: widget.category.text,
                    options: ProductCategories.getProductCategoriesList(),
                    onTaps: [ 
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.todos}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.ovos}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.brigadeirosTrufas}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.kitsCestas}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.datasComemorativas}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.formasEspeciais}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.barras}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${ProductCategories.outros}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                    ],
                  ),
                ),
                filterDrawerExpansionPanel(
                  isExpanded: expansionPanelsIsOpen[1],
                  title: 'Chocolate',
                  body: GroupRadioListTile(
                    currentOption: widget.typesChocolate.text,
                    options: TypesChocolate.getTypesChocolateList(),
                    onTaps: [
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.todos}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.aoLeite}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.branco}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.amargo}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.meioAmargo}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                      () => Navigator.pushNamed(context, "/search/${widget.query}/${widget.category}/${TypesChocolate.mesclado}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}"),
                    ],
                  ),
                ),
                filterDrawerExpansionPanel(
                  isExpanded: expansionPanelsIsOpen[2],
                  title: 'Preço',
                  body: Column(
                    children: [
                      Text(
                        'R\$ ${widget.currentPriceRange.start.round().toString()} - R\$ ${widget.currentPriceRange.end.round().toString()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      RangeSlider(
                        min: SearchPageFilterDrawer.minPrice,
                        max: SearchPageFilterDrawer.maxPrice,
                        values: widget.currentPriceRange,
                        // onChanged: (RangeValues values) {
                        //   setState(() {
                        //     widget.currentPriceRange = values;
                        //   });
                        //   Navigator.pushNamed(context, "/search/${widget.category}/${widget.typesChocolate}/${widget.currentPriceRange.start.round().toString()}/${widget.currentPriceRange.end.round().toString()}");
                        // },
                        onChanged: null,
                        activeColor: CSColors.primarySwatchV1.color,
                        inactiveColor: CSColors.secondaryV1.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
