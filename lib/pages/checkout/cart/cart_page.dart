// ignore_for_file: use_build_context_synchronously

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_item.dart';
import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_outline_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String subtotalPrice(List<CartItem>? cartItems) =>
    ViewUtils.formatDoubleToCurrency(CartService.getSubTotalPrice(cartItems ?? []));

  //Configurações visuais da página
  static const double pageSpacing = 32;
  static const double inputQtyPadding = 10;
  late Widget shippingFreightCartCard;
  Widget? content;
  Widget cartPageDivider = Divider(
    height: 0,
    thickness: 0.5,
    color: CSColors.secondaryV1.color,
    indent: 0,
    endIndent: 0,
  );

  Widget cartPageCard({
      required String title, 
      required Widget content,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CSTextSyles.mediumTitle(context),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: pageSpacing,
            ),
            child: content,
          ),
        ],
      );
  }

  Widget deleteIconButton(double size, CartService? cartService, String? cartItemId, DocumentReference? userRef) {
    return IconButton(
      onPressed: cartService != null
        ? () {
          cartService.removeCartItem(userRef!, cartItemId!);
        }
        : null,
      tooltip: 'Remover',
      icon: Icon(
        Icons.delete_outline_outlined,
        size: size,
      ),
    );
  }

  Widget inputQty({
    required int initVal,
    required CartItem cartItem,
    required CartService cartService,
    required DocumentReference userRef
  }){
    return InputQty(
      onQtyChanged: (value) async {
        cartItem.quantity = value;
        if(!await cartService.updateCartItem(userRef, cartItem)) {
          ScaffoldMessenger.of(context).showSnackBar(
            CSSnackBar(
              text: 'Houve um erro ao atualizar o carrinho. Caso o erro persista, entre em contato com o suporte.',
              actionType: CSSnackBarActionType.error,
            ),
          );
        }
      },
      initVal: initVal,
      minVal: 1,
      maxVal: 999,
      decoration: QtyDecorationProps(
        minusBtn: Padding(
          padding: const EdgeInsets.only(left: inputQtyPadding),
          child: Icon(
            Icons.remove,
            color: CSColors.primary.color,
            size: 18,
          ),
        ),
        plusBtn: Padding(
          padding: const EdgeInsets.only(right: inputQtyPadding),
          child: Icon(
            Icons.add,
            color: CSColors.primary.color,
            size: 18,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: inputQtyPadding),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    shippingFreightCartCard = cartPageCard(
      title: 'Prazo de entrega',
      content: CSTextFormField(
        enabled: false,
        controller: TextEditingController(),
        labelText: 'CEP',
        hintText: '00000-000',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CepInputFormatter(),
        ],
        suffixIcon: Container(
          width: 125,
          padding: const EdgeInsets.all(8),
          child: CSOutlineButton(
            onPressed: null,
            text:'Calcular',
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Widget summaryTotalCard(List<CartItem> cartItems) {
      return cartPageCard(
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
                    vertical: pageSpacing / 2,
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
                    ]
                  ),
                ),
                cartPageDivider,
              ];
            }).expand((element) => element).toList(),
            Container(
              margin: const EdgeInsets.only(
                top: pageSpacing,
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all(
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

    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return Consumer<CartService>(
          builder: (context, cartService, child) {
            cartService.refreshCart(usersServices.currentUsersDocRef);

            if(cartService.cartItems.isEmpty) {
              Future.delayed(const Duration(milliseconds: 3500), () {
                setState(() {
                  content = Container(
                    margin: const EdgeInsets.only(
                      top: 80,
                      right: pageSpacing,
                      left: pageSpacing,
                    ),
                    child: Text('Seu carrinho está vazio!',
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
              return content 
                  ?? Container(
                    alignment: Alignment.topCenter,
                    margin: const EdgeInsets.only(top: 80),
                    child: const CircularProgressIndicator()
                  );
            } 
            return SingleChildScrollView(
              child: Center(
                child: Container(
                  width: 950,
                  padding: EdgeInsets.only(
                    top: pageSpacing * (Responsive.isDesktop(context) ? 1.5 : 1),
                    bottom: pageSpacing * 2,
                    right: pageSpacing / 2,
                    left: pageSpacing / 2,
                  ),
                  child: Responsive.fullScreen(
                    desktop: Column(
                      children: [
                        Table(
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            1: FlexColumnWidth(20),
                            2: FlexColumnWidth(11),
                            3: FlexColumnWidth(9),
                            4: FixedColumnWidth(40),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.8,
                                    color: CSColors.secondaryV1.color,
                                  ),
                                ),
                              ),
                              children: [
                                Container(),
                                ...{'Produto', 'Quantidade', 'Total', '',}.map((value) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                Container(),
                              ],
                            ),
                            TableRow(
                              children: List.generate(6, (index) => const Gap(28))
                            ),
                            ... cartService.cartItems.map((item) {
                              return [
                                TableRow(
                                  children: [
                                    Container(),
                                    Container(
                                      height: 80,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            margin: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                return Image(
                                                  image: CachedNetworkImageProvider(
                                                    item.product == null || item.product!.imageUrl == null || item.product!.imageUrl!.isEmpty
                                                        ? 'https://www.allianceplast.com/wp-content/uploads/2017/11/no-image.png'
                                                        : item.product!.imageUrl!,
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
                                                );
                                              }
                                            ),
                                          ),
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: CSColors.primary.color,
                                                ),
                                                children: [
                                                  TextSpan(text: item.product!.description ?? 'Erro ao carregar informações do produto!',),
                                                  TextSpan(
                                                    text: '\n${ViewUtils.formatDoubleToCurrency(item.product!.unitPrice ?? 0)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      color: CSColors.secondaryV1.color,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: inputQty(
                                        initVal: item.quantity!,
                                        cartItem: item,
                                        cartService: cartService,
                                        userRef: usersServices.currentUsersDocRef,
                                      ),
                                    ),
                                    Text(
                                      ViewUtils.formatDoubleToCurrency((item.product!.unitPrice ?? 0) * item.quantity!),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      child: deleteIconButton(24, cartService, item.id, usersServices.currentUsersDocRef),
                                    ),
                                    Container(),
                                  ],
                                ),
                                TableRow(
                                  children: List.generate(6, (index) => const Gap(pageSpacing))
                                ),
                              ];
                            }).expand((element) => element).toList(),
                            TableRow(
                              decoration: BoxDecoration(
                                color: CSColors.foreground.color,
                                borderRadius: const BorderRadius.all(Radius.circular(5)),
                              ),
                              children: [
                                const Gap(40),
                                Container(),
                                const Text(
                                  'Subtotal:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  )
                                ),
                                Text(
                                  subtotalPrice(cartService.cartItems),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  )
                                ),
                                Container(),
                                Container(),
                              ],
                            ),
                          ]
                        ),
                        const Gap(pageSpacing * 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(child: shippingFreightCartCard),
                            const Gap(pageSpacing * 2),
                            Flexible(child: summaryTotalCard(cartService.cartItems)),
                          ],
                        ),
                      ],
                    ),
                    mobile: Column(
                      children: [
                        ... cartService.cartItems.map((item) {
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                padding: EdgeInsets.only(
                                  top: item == cartService.cartItems.first ? 0 : pageSpacing,
                                  bottom: pageSpacing,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 0.8,
                                      color: CSColors.secondaryV1.color,
                                    )
                                  )
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.product!.description ?? 'Erro ao carregar informações do produto!',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: CSColors.primary.color,
                                            ),
                                          ),
                                        ),
                                        deleteIconButton(18, cartService, item.id, usersServices.currentUsersDocRef),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${ViewUtils.formatDoubleToCurrency(item.product!.unitPrice ?? 0)} unid.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: CSColors.secondaryV1.color,
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
                                          item.product == null || item.product!.imageUrl == null || item.product!.imageUrl!.isEmpty
                                              ? 'https://www.allianceplast.com/wp-content/uploads/2017/11/no-image.png'
                                              : item.product!.imageUrl!,
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        inputQty(
                                          initVal: item.quantity!,
                                          cartItem: item,
                                          cartService: cartService,
                                          userRef: usersServices.currentUsersDocRef,
                                        ),
                                        Text(
                                          ViewUtils.formatDoubleToCurrency((item.product!.unitPrice ?? 0) * item.quantity!),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          );
                        }).toList(),
                        const Gap(pageSpacing * 2 + 24),
                        shippingFreightCartCard,
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: pageSpacing,
                          ),
                          child: cartPageDivider,
                        ),
                        summaryTotalCard(cartService.cartItems),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }
}
