// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_item.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/models/product/product_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/card_registro_nao_encontrado.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String? productId;

  const ProductDetailPage({
    super.key,
    this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const double inputQtyPadding = 5;
  final ProductService productService = ProductService();
  int quantity = 1;
  double? _totalPrice;
  Widget? streamHasNoDataContent;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {  
        return Consumer<CartService>(
          builder: (context, cartService, child) {
            return StreamBuilder<DocumentSnapshot>(
              stream: productService.getProductStreamById(widget.productId),
              builder: (context, snapshot) {
                if(snapshot.hasError) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Text('Erro ao carregar os dados! Caso o erro persista, entre em contato com o suporte.',
                        textAlign: TextAlign.center,
                        style: CSTextSyles.alertText(context),
                      ),
                    ),
                  );
                } else if((!snapshot.hasData || snapshot.data == null || snapshot.data!.exists == false)) {
                  Future.delayed(const Duration(milliseconds: 2000), () {
                            setState(() {
                              streamHasNoDataContent = const CardRegistroNaoEncontrado(
                                registerName: 'Produto',
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
                  Product product = Product.fromJson(snapshot.data!);

                  return Center(
                    child: Container(
                      width: 600,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: Responsive.isDesktop(context) ? 70 : 64,
                        top: Responsive.isDesktop(context) ? 64 : 32,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: CSColors.primary.color,
                                      fontWeight: FontWeight.w500,
                                      height: 1.75,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: product.description ?? 'Erro ao carregar informações do produto!',
                                        style: TextStyle(
                                          height: 1.2,
                                          fontSize: Responsive.isDesktop(context) ? 26 : 24,
                                        ),
                                      ),
                                      TextSpan(
                                        text: product.deleted! ? ' - ' : '',
                                        style: TextStyle(
                                          height: 1.2,
                                          fontSize: Responsive.isDesktop(context) ? 26 : 24,
                                        )
                                      ),
                                      TextSpan(
                                        text: product.deleted! ? 'Produto Desativado' : '',
                                        style: TextStyle(
                                          color: CSColors.errorText.color,
                                          height: 1.2,
                                          fontSize: Responsive.isDesktop(context) ? 26 : 24,
                                        ),
                                      ),
                                      TextSpan(
                                        text: product.typeChocolate != null && product.typeChocolate!.isNotEmpty
                                            ? '\nTipo de chocolate: ${product.typeChocolate}'
                                            : '',
                                        style: TextStyle(
                                          color: CSColors.secondaryV1.color,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: product.category != null && product.category!.isNotEmpty
                                            ? '\nCategoria: ${product.category}'
                                            : '',
                                        style: TextStyle(
                                          color: CSColors.secondaryV1.color,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n${ViewUtils.formatDoubleToCurrency(product.unitPrice ?? 0)} unid.',
                                        style: TextStyle(
                                          color: CSColors.secondaryV1.color,
                                          fontSize: Responsive.isDesktop(context) ? 16 : 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 16,
                                  bottom: 24,
                                ),
                                child: Image(
                                  image: CachedNetworkImageProvider(
                                    product.imageUrl!,
                                    maxWidth: constraints.maxWidth.toInt(),
                                    maxHeight: constraints.maxWidth.toInt(),
                                  ),
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      width: constraints.maxWidth,
                                      height: constraints.maxWidth,
                                      child: Center(
                                        child: Text('Erro ao carregar a imagem!',
                                          textAlign: TextAlign.center,
                                          style: CSTextSyles.alertText(context),
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: CSColors.secondaryV1.color,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 65,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          ViewUtils.formatDoubleToCurrency(_totalPrice ?? product.unitPrice ?? 0),
                                          style: TextStyle(
                                            fontSize: Responsive.isDesktop(context) ? 18 : 18,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        InputQty(
                                          initVal: 1,
                                          minVal: 1,
                                          maxVal: 999,
                                          decimalPlaces: 0,
                                          onQtyChanged: (val) {
                                            setState(() {
                                              quantity = val.round();
                                              _totalPrice = product.unitPrice != null
                                                  ? product.unitPrice! * quantity
                                                  : 0;
                                            });
                                          },
                                          decoration: QtyDecorationProps(
                                            contentPadding: const EdgeInsets.symmetric(vertical: inputQtyPadding),
                                            minusBtn: Padding(
                                              padding: const EdgeInsets.only(left: inputQtyPadding),
                                              child: Icon(
                                                Icons.remove,
                                                color: CSColors.primary.color,
                                                size: Responsive.isDesktop(context) ? 18 : 16,
                                              ),
                                            ),
                                            plusBtn: Padding(
                                              padding: const EdgeInsets.only(right: inputQtyPadding),
                                              child: Icon(
                                                Icons.add,
                                                color: CSColors.primary.color,
                                                size: Responsive.isDesktop(context) ? 18 : 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: Responsive.isDesktop(context) 
                                        ? 225
                                        : MediaQuery.of(context).size.width > 550
                                            ? 200
                                            : MediaQuery.of(context).size.width > 350
                                                ? 150
                                                : 90,
                                    child: ElevatedButton(
                                      onPressed: !product.deleted! 
                                          ? () async {
                                            if (await cartService.addCartItem(usersServices.currentUsersDocRef, CartItem(
                                              userRef: usersServices.currentUsersDocRef,
                                              productRef: await productService.getProductRefById(product.id),
                                              quantity: quantity,
                                            ))) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                CSSnackBar(
                                                  text: 'Produto adicionado ao carrinho!',
                                                  actionType: CSSnackBarActionType.success,
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                CSSnackBar(
                                                  text: 'Erro ao adicionar o produto ao carrinho!',
                                                  actionType: CSSnackBarActionType.error,
                                                ),
                                              );
                                            }
                                          }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: const Size.fromHeight(65),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.all(
                                          Responsive.isDesktop(context) ? 16 : 8, 
                                        ),
                                      ),
                                      child: MediaQuery.of(context).size.width > 350
                                          ? Text(
                                            !product.deleted!
                                                ? 'Adicionar ao carrinho'
                                                 : 'Produto Desativado',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: CSColors.primary.color,
                                              fontSize: Responsive.isDesktop(context) ? 18 : 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                          : Icon(
                                            !product.deleted!
                                                ? Icons.add_shopping_cart
                                                : Icons.remove_shopping_cart,
                                            size: 34,
                                            color: CSColors.primary.color,
                                          ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          );
                        }
                      ),
                    ),
                  );
                }
              }
            );
          }
        );
      }
    );
  }
}
