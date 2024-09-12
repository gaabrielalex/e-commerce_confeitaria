// ignore_for_file: use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/cart/cart_service.dart';
import 'package:confeitaria_divine_cacau/models/payment/payment.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale_item.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/checkout_page.dart';
import 'package:confeitaria_divine_cacau/pages/checkout/components/payment_option.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final UsersServices usersServices;
  final CartService cartService;

  const PaymentPage({
    super.key,
    required this.usersServices,
    required this.cartService,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Widget summaryTotalCard;
  final SaleService _saleService = SaleService();
  final Map<PaymentMethod, BooleanController> conjunctionPaymentMethodSelected =
      {};
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    summaryTotalCard = CheckoutPage.summaryTotalCard(
        cartItems: widget.cartService.cartItems,
        onPressed: () async{
          if (_selectedPaymentMethod == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              CSSnackBar(
                  text:
                      'Selecione um método de pagamento para finalizar a compra.',
                  actionType: CSSnackBarActionType.error),
            );
          } else if (_selectedPaymentMethod == PaymentMethod.creditCard ||
              _selectedPaymentMethod == PaymentMethod.debitCard) {
            ScaffoldMessenger.of(context).showSnackBar(
              CSSnackBar(
                  text:
                      'Este método de pagamento não está disponível no momento.',
                  actionType: CSSnackBarActionType.error),
            );
          } else {
            try {
              var response = await _saleService.addSale(
                Sale(
                  userRef: widget.usersServices.currentUsersDocRef,
                  status: SaleStatus.pending,
                  items: widget.cartService.cartItems
                      .map((cartItem) => SaleItem.fromCartItem(cartItem))
                      .toList(),
                  subTotal: widget.cartService.subTotal,
                  delivery: widget.cartService.delivery,
                  payment: Payment(
                    paymentMethod: _selectedPaymentMethod!,
                    paymentAmount: widget.cartService.totalPrice,
                  ),
                ),
              );
              if (!response) {
                throw Exception('Erro ao finalizar a compra. Tente novamente.');
              }
              
              await widget.cartService.clearCart();
              Navigator.of(context).pushReplacementNamed('/home');
              ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                    text: 'Compra finalizada com sucesso!',
                    actionType: CSSnackBarActionType.success),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                    text: 'Erro ao finalizar a compra. Tente novamente.',
                    actionType: CSSnackBarActionType.error),
              );
            }
          }
        });

    for (var paymentMethod in PaymentMethod.values) {
      conjunctionPaymentMethodSelected[paymentMethod] = BooleanController();
    }

    // Ação para definir o valor dos controladores e controlar a seleção única
    for (var entry in conjunctionPaymentMethodSelected.entries) {
      entry.value.onSetValue = (controllerSet, value) {
        if (value) {
          setState(() {
            _selectedPaymentMethod = entry.key;
          });
        }
        for (var controller in conjunctionPaymentMethodSelected.values) {
          if (controller.id != controllerSet.id && controller.value) {
            controller.set(false);
          }
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isDesktop(context) ? 50 : 0,
      ),
      child: Column(
        children: [
          Responsive.isDesktop(context)
              ? Row(children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: _paymentOptions(),
                    ),
                  ),
                  // Painel central com as instruções do pagamento selecionado
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildPaymentContent(),
                      ),
                    ),
                  ),
                ])
              : Column(
                  children: [
                    ..._paymentOptions(),
                    Card(
                      margin: const EdgeInsets.only(top: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildPaymentContent(),
                      ),
                    ),
                  ],
                ),
          CheckoutPage.cartPageDividerWithSpacing(context),
          summaryTotalCard,
        ],
      ),
    );
  }

  List<Widget> _paymentOptions() {
    return [
      PaymentOption(
        icon: Icons.qr_code,
        label: PaymentMethod.pix.name,
        onSelected: conjunctionPaymentMethodSelected[PaymentMethod.pix]!,
      ),
      PaymentOption(
        icon: Icons.credit_card,
        label: PaymentMethod.debitCard.name,
        onSelected: conjunctionPaymentMethodSelected[PaymentMethod.debitCard]!,
      ),
      PaymentOption(
        icon: Icons.credit_card_outlined,
        label: PaymentMethod.creditCard.name,
        onSelected: conjunctionPaymentMethodSelected[PaymentMethod.creditCard]!,
      ),
      PaymentOption(
        icon: Icons.money,
        label: PaymentMethod.money.name,
        onSelected: conjunctionPaymentMethodSelected[PaymentMethod.money]!,
      ),
    ];
  }

  Widget _textPaymentContent(String text, {Color? color}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Função para alterar o conteúdo do Card com base no método selecionado
  Widget _buildPaymentContent() {
    if (_selectedPaymentMethod == null) {
      return _textPaymentContent('Selecione um método de pagamento');
    }

    switch (_selectedPaymentMethod) {
      case PaymentMethod.pix:
        return Center(
          child: Column(
            children: [
              Image.asset('assets/images/icons/logo-pix-1024.png', height: 65),
              const SizedBox(height: 20),
              const Text(
                '1° Aperte em Finalizar compra para gerar o código QR',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                '2° Confira os dados e realize o pagamento pelo app do seu banco',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case PaymentMethod.debitCard:
      case PaymentMethod.creditCard:
        return _textPaymentContent(
            "Este método de pagamento não está disponível no momento!",
            color: CSColors.errorText.color);
      case PaymentMethod.money:
        return _textPaymentContent(
            "O pagamento em dinheiro deve ser feito no ato da entrega.");
      default:
        return const SizedBox.shrink();
    }
  }
}
