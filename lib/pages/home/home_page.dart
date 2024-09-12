import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_search/widgets/search_page_filter_drawer.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/home_page_category.dart';
import 'package:flutter/material.dart';
import 'package:confeitaria_divine_cacau/util/widgets/layouts/emphasis_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return EmphasisContainer(
      child: Container(
        width: 1200,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              HomePageCategory(
                text: ProductCategories.ovos.text,
                iconPath: "assets/images/icons/icons8-easter-48.png",
                onTap: () {
                  Navigator.pushNamed(context,
                     "/search/Todos/${ProductCategories.ovos}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
              HomePageCategory(
                text: ProductCategories.brigadeirosTrufas.text,
                iconPath: "assets/images/icons/icons8-candy-48.png",
                onTap: () {
                  Navigator.pushNamed(context, 
                    "/search/Todos/${ProductCategories.brigadeirosTrufas}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
              HomePageCategory(
                text: ProductCategories.kitsCestas.text,
                iconData: Icons.shopping_basket_outlined,
                onTap: () {
                  Navigator.pushNamed(context,
                      "/search/Todos/${ProductCategories.kitsCestas}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
              HomePageCategory(
                text: ProductCategories.datasComemorativas.text,
                iconData: Icons.cake_outlined,
                onTap: () {
                  Navigator.pushNamed(context,
                      "/search/Todos/${ProductCategories.datasComemorativas}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
              HomePageCategory(
                text: ProductCategories.formasEspeciais.text,
                iconData: Icons.star_border_outlined,
                onTap: () {
                  Navigator.pushNamed(context,
                      "/search/Todos/${ProductCategories.formasEspeciais}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
              HomePageCategory(
                text: ProductCategories.barras.text,
                iconPath: "assets/images/icons/icons8-chocolate-bar-48.png",
                onTap: () {
                  Navigator.pushNamed(context,
                      "/search/Todos/${ProductCategories.barras}/${TypesChocolate.todos}/${SearchPageFilterDrawer.minPrice}/${SearchPageFilterDrawer.maxPrice}");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
