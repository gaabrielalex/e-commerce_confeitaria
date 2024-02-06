// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/models/product/product_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_forms/default_form/default_form_of_product.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/picked_image/picked_image_service.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductRegistrationPage extends StatefulWidget {
  const ProductRegistrationPage({super.key});

  @override
  State<ProductRegistrationPage> createState() => _ProductRegistrationPageState();
}

class _ProductRegistrationPageState extends State<ProductRegistrationPage> {
  final ProductService _productService = ProductService();  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _selectedCategory = TextEditingController();
  final TextEditingController _selectedChocolateType = TextEditingController();
  final TextEditingController _unitPrice = TextEditingController();
  final TextEditingController _quantityInStock = TextEditingController();
  final BooleanController _onDemand = BooleanController();

  @override
  Widget build(BuildContext context) {
    _onDemand.set(true);

    return Consumer<UsersServices>(
      builder: (context, usersServices, child) {
        return DefaultFormOfProduct(
          formKey: _formKey,
          title: 'Novo produto',
          descriptionController: _description,
          selectedCategoryController: _selectedCategory,
          selectedChocolateTypeController: _selectedChocolateType,
          unitPriceController: _unitPrice,
          quantityInStockController: _quantityInStock,
          onDemand: _onDemand,
          onCancel: () => Navigator.pushNamed(context, '/account/overview'),
          onSave: () async {
            ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                  text: 'Estamos realizando o cadastro do produto. Aguarde um momento...',
                  actionType: CSSnackBarActionType.info,
                  duration: const Duration(milliseconds: 10000),
                ),
              );    
            double? unitPrice = double.tryParse(_unitPrice.text.replaceAll(RegExp(r"[^0-9,]"), "").replaceAll(',', '.'));

            bool response = await _productService.addProduct(
              product: Product(
                lastUserToUpdate: usersServices.currentUsersDocRef,
                description: _description.text,
                category: _selectedCategory.text,
                typeChocolate: _selectedChocolateType.text,
                unitPrice: unitPrice,
                quantityInStock: !_onDemand.value
                    ? int.tryParse(_quantityInStock.text)
                    : null,
                onDemand: _onDemand.value,
              ),
              imageFile: kIsWeb 
                  ? Provider.of<PickedImageService>(context, listen: false).webImage
                  : Provider.of<PickedImageService>(context, listen: false).pickImage,
              platIsWeb: kIsWeb,
            );
            if (response) {
              //Limpa os campos
              setState(() {
                Provider.of<PickedImageService>(context, listen: false).pickImage = null;
                Provider.of<PickedImageService>(context, listen: false).webImage = null;
                _selectedCategory.text = "";
                _selectedChocolateType.text = "";
              });
              _description.clear();
              _unitPrice.clear();
              _quantityInStock.clear();
              //Mostra a mensagem de sucesso e apaga a mensagem de aguarde
              ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                  text: 'Cadastro realizado com sucesso!',
                  actionType: CSSnackBarActionType.success,
                ),
              );
               ScaffoldMessenger.of(context).removeCurrentSnackBar();
              // Navigator.pushNamed(context, '/account/overview');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                CSSnackBar(
                  text: 'Houve um erro ao realizar o cadastro. Caso o erro persista, entre em contato com o suporte.',
                  actionType: CSSnackBarActionType.error,
                ),
              );
            }
          },
        );
      }
    );
  }
}
