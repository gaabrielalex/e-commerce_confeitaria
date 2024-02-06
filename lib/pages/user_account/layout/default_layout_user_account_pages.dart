import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/view/view_utils.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_back_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DefaultLayoutUserAccountPages extends StatelessWidget {
  final Widget chield;
  final void Function()? onPressedBackButton;

  const DefaultLayoutUserAccountPages({
    Key? key,
    required this.chield,
    this.onPressedBackButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: 32,
        bottom: Responsive.isDesktop(context) ? 64 : 32,
        left: ViewUtils.defaultMobileContentHorizontalPadding,
        right: ViewUtils.defaultMobileContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CSBackButton(
            onPressed: onPressedBackButton ?? () => Navigator.pushNamed(context, '/account/overview'),
          ),
          Responsive.isDesktop(context)
              ? const Gap(ViewUtils.formsGapSize * 17 / 9)
              : const Gap(ViewUtils.formsGapSize),
          chield
        ],
      ),
    );
  }
}