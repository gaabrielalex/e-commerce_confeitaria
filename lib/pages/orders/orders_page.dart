import 'package:confeitaria_divine_cacau/models/delivery/delivery.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale.dart';
import 'package:confeitaria_divine_cacau/models/sale/sale_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final SaleService _saleService = SaleService();
  Widget? streamHasNoDataContent;

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(builder: (context, usersServices, child) {
      return DefaultLayoutUserAccountPages(
        onPressedBackButton: () => Navigator.pop(context),
        child: DefaultForm(
            title: 'Meus Pedidos',
            isListing: true,
            isStream: true,
            stream: _saleService
                .getAllSalesStreamByUser(usersServices.currentUsersDocRef),
                        streamHasNoDataContent: streamHasNoDataContent,
            streamOnHasNoData: () {
              Future.delayed(const Duration(milliseconds: 2000), () {
                setState(() {
                  streamHasNoDataContent = Text("Nenhum pedido encontrado!",
                    textAlign: TextAlign.center,
                    style: CSTextSyles.alertText(context),
                  );
                });
              });
            },
            contentBuilder: (snapshots) {
              return ListView(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  //Adicionando todos os endereços do usuário
                  ...snapshots.data!.docs.map((salesSnapshot) {
                    Sale sale = Sale.fromJson(salesSnapshot);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: Padding(           
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text('Pedido #${sale.id}'),
                            titleTextStyle: TextStyle(
                              color: CSColors.primary.color,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              letterSpacing: 0.8,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(sale.createdAt!)}'),
                                Text('Status: ${sale.status!.name}'), 
                                Text('Subtotal: ${ViewUtils.formatDoubleToCurrency(sale.subTotal!)}'),
                                Text('Frete: ${ViewUtils.formatDoubleToCurrency(sale.delivery!.deliveryPrice!)}'),
                                Text('Total: ${ViewUtils.formatDoubleToCurrency(sale.total!)}'),
                                Text('Pagamento: ${sale.payment!.paymentMethod!.name}'),
                                Text('Entrega: ${(sale.delivery!.deliveryCategory! == DeliveryCategories.delivery) ? 'Endereço escolhido' : sale.delivery!.deliveryCategory!.name}'),
                                // ...sale.items!.map((item) {
                                //   return Text(
                                //       '${item.product!.description} - R\$ ${item.product!.unitPrice}');
                                // }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }),
      );
    });
  }
}
