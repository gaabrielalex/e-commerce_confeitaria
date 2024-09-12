// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/models/product/product_service.dart';
import 'package:confeitaria_divine_cacau/models/users/users_service.dart';
import 'package:confeitaria_divine_cacau/pages/product/product_forms/default_form/default_form_of_product.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/picked_image/picked_image_service.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductEditPage extends StatefulWidget {
  final String? productId;

  const ProductEditPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final ProductService _productService = ProductService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //Improviso para não ter que criar um nova controller específica para a imagem
  final TextEditingController _imageUrl = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _selectedCategory = TextEditingController();
  final TextEditingController _selectedChocolateType = TextEditingController();
  final TextEditingController _unitPrice = TextEditingController();
  final TextEditingController _quantityInStock = TextEditingController();
  final BooleanController _onDemand = BooleanController();
  final BooleanController _deleted = BooleanController();
  Widget? streamHasNoDataContent;
  Product? productToUpdate;

   @override
  void initState() {
    super.initState();
    _initializeAsyncData();
  }

  Future<void> _initializeAsyncData() async {
  
    try {
      final snapshot = await _productService.getProductById(widget.productId);
      productToUpdate = (snapshot != null) ? Product.fromJson(snapshot) : null;
    } catch (e) {
      debugPrint(e.toString());
      return;
    }

    setState(() {
      if (productToUpdate!.imageUrl != null) {
        _imageUrl.text = productToUpdate!.imageUrl!;
      }
      _description.text = productToUpdate!.description!;
      _selectedCategory.text = productToUpdate!.category!;
      _selectedChocolateType.text = productToUpdate!.typeChocolate!;
      _unitPrice.text =
          ViewUtils.formatDoubleToCurrency(productToUpdate!.unitPrice!);
      _quantityInStock.text = productToUpdate!.quantityInStock != null
          ? productToUpdate!.quantityInStock.toString()
          : "";
      _onDemand.set(productToUpdate!.onDemand!);
      _deleted.set(productToUpdate!.deleted!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersServices>(builder: (context, usersServices, child) {
      return DefaultFormOfProduct(
        formKey: _formKey,
        title: 'Editar produto',
        imageUrl: _imageUrl,
        descriptionController: _description,
        selectedCategoryController: _selectedCategory,
        selectedChocolateTypeController: _selectedChocolateType,
        unitPriceController: _unitPrice,
        quantityInStockController: _quantityInStock,
        onDemand: _onDemand,
        onPressedBackButton: () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
        onSave: () async {
          if (productToUpdate == null) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            CSSnackBar(
              text:
                  'O processo de edição do produto está sendo realizado. Aguarde um momento...',
              actionType: CSSnackBarActionType.info,
              duration: const Duration(milliseconds: 10000),
            ),
          );
          double? unitPrice = double.tryParse(_unitPrice.text
              .replaceAll(RegExp(r"[^0-9,]"), "")
              .replaceAll(',', '.'));

          bool response = await _productService.updateProduct(
            productId: widget.productId!,
            product: Product(
              lastUserToUpdate: usersServices.currentUsersDocRef,
              description: _description.text,
              category: _selectedCategory.text,
              typeChocolate: _selectedChocolateType.text,
              unitPrice: unitPrice,
              quantityInStock:
                  !_onDemand.value ? int.tryParse(_quantityInStock.text) : null,
              onDemand: _onDemand.value,
              deleted: _deleted.value,
              imageUrl: _imageUrl.text,
            ),
            imageFile: (Provider.of<PickedImageService>(context, listen: false)
                            .webImage !=
                        null ||
                    Provider.of<PickedImageService>(context, listen: false)
                            .pickImage !=
                        null)
                ? kIsWeb
                    ? Provider.of<PickedImageService>(context, listen: false)
                        .webImage
                    : Provider.of<PickedImageService>(context, listen: false)
                        .pickImage
                : null,
            platIsWeb: kIsWeb,
          );
          if (response) {
            //Mostra a mensagem de sucesso e apaga a mensagem de aguarde
            ScaffoldMessenger.of(context).showSnackBar(
              CSSnackBar(
                text: 'Produto atualizado com sucesso!',
                actionType: CSSnackBarActionType.success,
              ),
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            // Navigator.pushNamed(context, '/account/overview');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              CSSnackBar(
                text:
                    'Houve um erro ao atualizar o produto. Caso o erro persista, entre em contato com o suporte.',
                actionType: CSSnackBarActionType.error,
              ),
            );
          }
        },
      );
    });
  }
}
