// ignore_for_file: must_be_immutable

import 'package:confeitaria_divine_cacau/util/boolean_controller/boolean_controller.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_colors.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddressCard extends StatefulWidget {
  static const double iconSize = 20;
  final Function()? onEdit;
  final Function()? onConfirmDelete;
  final bool disableDelete;
  final bool isSelectable;
  final String? addressIdentification;
  final String? address;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? city;
  final String? stateAcronym;
  final String? zipCode;
  BooleanController? onSelectedController;
  final Function(bool)? onSelected;


  AddressCard({
    super.key,
    this.onEdit,
    this.onConfirmDelete,
    this.disableDelete = false,
    this.isSelectable = false,
    required this.addressIdentification,
    this.address = '',
    this.number = '',
    this.complement = '',
    this.neighborhood = '',
    this.city = '',
    this.stateAcronym = '',
    this.zipCode = '',
    this.onSelectedController,
    this.onSelected,
  });

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  final Color iconColor = CSColors.secondaryV1.color;

  @override
  initState() {
    super.initState();
    widget.onSelectedController ??= BooleanController();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.addressIdentification!,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 18,
                    letterSpacing: 0.75,
                    color: CSColors.primary.color,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
              if (widget.isSelectable)
                Checkbox(
                  value: widget.onSelectedController!.value,
                  onChanged: (value) {
                    setState(() {
                      widget.onSelectedController!.set(value!);
                      widget.onSelected?.call(value);
                    });
                  },
                  fillColor: widget.onSelectedController!.value
                      ? WidgetStateProperty.all<Color?>(
                          CSColors.primarySwatchV1.color)
                      : WidgetStateProperty.all<Color?>(Colors.transparent),
                ),
            ],
          ),
          const Gap(10),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
                '${widget.address}, ${widget.number}${widget.complement!.isNotEmpty ? ' - ${widget.complement}\n' : '\n'}'
                '${widget.neighborhood} - ${widget.city} - ${widget.stateAcronym}\n'
                'Cep: ${widget.zipCode}',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  color: CSColors.secondaryV1.color,
                )),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: widget.onEdit ?? () {},
                tooltip: 'Editar',
                icon: Icon(
                  Icons.edit_outlined,
                  size: AddressCard.iconSize,
                  color: iconColor,
                ),
              ),
              if (!widget.disableDelete)
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Excluir endereço'),
                            content: const Text(
                                'Tem certeza que deseja excluir este endereço?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  if (widget.onConfirmDelete != null) {
                                    widget.onConfirmDelete!.call();
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Excluir'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          );
                        });
                  },
                  tooltip: 'Excluir',
                  icon: Icon(
                    ViewUtils.defaultDeleteIcon,
                    size: AddressCard.iconSize,
                    color: iconColor,
                  ),
                ),
            ],
          )
        ],
      ),
    ));
  }
}
