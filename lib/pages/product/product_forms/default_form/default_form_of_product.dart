// ignore_for_file: must_be_immutable

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confeitaria_divine_cacau/models/product/product.dart';
import 'package:confeitaria_divine_cacau/pages/user_account/layout/default_layout_user_account_pages.dart';
import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/picked_image/picked_image_service.dart';
import 'package:confeitaria_divine_cacau/util/picked_image/picked_image_widget.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_dropdown_button.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_text_form_field.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/default_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DefaultFormOfProduct extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String title;
  final bool isStream;
  final Stream<dynamic>? stream;
  final void Function()? onSave;
  final void Function()? onCancel;
  final void Function(AsyncSnapshot<dynamic>)? beforeBuildingContent;
  final void Function()? onPressedBackButton;
  final void Function()? streamOnHasNoData;
  //Improviso para não ter que criar um nova controller específica para a imagem
  final TextEditingController? imageUrl;
  final TextEditingController? descriptionController;
  final TextEditingController? unitPriceController;
  final TextEditingController? quantityInStockController; 
  TextEditingController? selectedCategoryController;
  TextEditingController? selectedChocolateTypeController;
  BooleanController? onDemand;
  final Widget? streamHasNoDataContent;

  DefaultFormOfProduct({
    super.key,
    required this.formKey,
    required this.title,
    this.isStream = false,
    this.stream,
    this.imageUrl,
    this.descriptionController,
    this.unitPriceController,
    this.quantityInStockController,
    this.selectedCategoryController,
    this.selectedChocolateTypeController,
    this.onDemand,
    this.onSave,
    this.onCancel,
    this.beforeBuildingContent,
    this.onPressedBackButton,
    this.streamOnHasNoData,
    this.streamHasNoDataContent,
  });

  @override
  State<DefaultFormOfProduct> createState() => _DefaultFormOfProductState();
}

class _DefaultFormOfProductState extends State<DefaultFormOfProduct> {
  String? imageValidateMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        Provider.of<PickedImageService>(context, listen: false).pickImage = null;
        Provider.of<PickedImageService>(context, listen: false).webImage = null;
      });
    }); 
  }

  @override
  Widget build(BuildContext context) {
    widget.selectedCategoryController ??= TextEditingController();
    widget.selectedChocolateTypeController ??= TextEditingController();
    widget.onDemand ??= BooleanController();

    return DefaultLayoutUserAccountPages(
      onPressedBackButton: widget.onPressedBackButton,
      child: DefaultForm(
        formKey: widget.formKey,
        title: widget.title,
        isStream: widget.isStream,
        stream: widget.stream,
        streamOnHasNoData: widget.streamOnHasNoData,
        streamHasNoDataContent: widget.streamHasNoDataContent,
        onCancel: widget.onCancel,
        onSave: () async {
          setState(() {
            if((Provider.of<PickedImageService>(context, listen: false).pickImage == null 
              || Provider.of<PickedImageService>(context, listen: false).webImage!.isEmpty)
              & !(widget.imageUrl != null && widget.imageUrl!.text.isNotEmpty)) {
                imageValidateMessage = 'Selecione uma imagem para continuar';
            } else {
              imageValidateMessage = null;
            }
          });
          if(widget.formKey.currentState!.validate() && imageValidateMessage == null) {
            widget.onSave?.call();
          }
        },
        contentBuilder: (snapshot) {
          if(widget.beforeBuildingContent != null) {
            widget.beforeBuildingContent?.call(snapshot);
          }
          return Wrap(
            runSpacing: ViewUtils.formsGapSize,
            children: [
              Consumer<PickedImageService>(
                builder: (context, pickedImgService, child) {
                  return PickedImageWidget(
                    validateMessage: imageValidateMessage,
                    readImage: () {
                      pickedImgService.pickImageFromGallery();
                    },
                    image: !(pickedImgService.pickImage == null || pickedImgService.webImage!.isEmpty)
                        ? kIsWeb
                            ? Image.memory(
                                pickedImgService.webImage!,
                                width: PickedImageWidget.defaultDimension,
                                height: PickedImageWidget.defaultDimension,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                pickedImgService.pickImage!,
                                width: PickedImageWidget.defaultDimension,
                                height: PickedImageWidget.defaultDimension,
                                fit: BoxFit.cover,
                              )
                          :  (widget.imageUrl != null && widget.imageUrl!.text.isNotEmpty)
                              ? Image(
                                  image: CachedNetworkImageProvider(
                                    widget.imageUrl!.text,
                                    maxWidth: PickedImageWidget.defaultDimension.toInt(),
                                    maxHeight: PickedImageWidget.defaultDimension.toInt(),
                                  ),
                                  width: PickedImageWidget.defaultDimension,
                                  height: PickedImageWidget.defaultDimension,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.low,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text('Erro ao carregar a imagem!',
                                        textAlign: TextAlign.center,
                                        style: CSTextSyles.alertText(context),
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
                                )
                          : null,
                  );
                },
              ),
              CSTextFormField(
                controller: widget.descriptionController,
                labelText: 'Descrição',
                maxLength: 100,
                validator: ViewUtils.validateRequiredField,
              ),
              CSDropdownButton(
                menuHeight: 210,
                selectedItem: widget.selectedCategoryController!.text.isEmpty 
                    ? null
                    : widget.selectedCategoryController!.text,
                labelText: 'Categoria',
                items: ProductCategories.getProductCategoriesList(),
                onChanged: (value) {
                  widget.selectedCategoryController!.text = value!;
                },
                validator: ViewUtils.validateRequiredField,
              ),
              CSDropdownButton(
                selectedItem: widget.selectedChocolateTypeController!.text.isEmpty 
                    ? null
                    : widget.selectedChocolateTypeController!.text,
                labelText: 'Tipo de chocolate (Opcional)',
                items: TypesChocolate.getTypesChocolateList(),
                onChanged: (value) {
                  widget.selectedChocolateTypeController!.text = value!;
                },
                // validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.unitPriceController,
                labelText: 'Preço unitário',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CentavosInputFormatter(moeda: true),
                ],
                validator: ViewUtils.validateRequiredField,
              ),
              CSTextFormField(
                controller: widget.quantityInStockController,
                enabled: !widget.onDemand!.value,
                labelText: 'Quantidade em estoque',
                maxLength: 5,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: !widget.onDemand!.value
                    ? ViewUtils.validateRequiredField
                    : null,
              ),
              SizedBox(
                width: 200,
                child: CheckboxListTile(
                  title: const Text('Por demanda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  fillColor: widget.onDemand!.value 
                      ? WidgetStateProperty.all<Color?>(CSColors.primarySwatchV1.color) 
                      : WidgetStateProperty.all<Color?>(Colors.transparent),
                  value: widget.onDemand!.value,
                  onChanged: (value) {
                    setState(() {
                      widget.onDemand!.set(value!);
                    });
                  },  
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
