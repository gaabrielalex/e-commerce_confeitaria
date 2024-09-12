import 'package:confeitaria_divine_cacau/pages/checkout/checkout_page.dart';
import 'package:confeitaria_divine_cacau/util/responsive/responsive.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:confeitaria_divine_cacau/util/widgets/actions/cs_outline_button.dart';
import 'package:flutter/material.dart';

class CartPageCard extends StatelessWidget {
  final String title;
  final Widget content;
  final String? textButton;
  final void Function()? onPressedButton;

  const CartPageCard({
    super.key,
    required this.title,
    required this.content,
    this.textButton,
    this.onPressedButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: CSTextSyles.mediumTitle(context),
              ),
            ),
            if (textButton != null)
              Responsive.isDesktop(context)
                  ? SizedBox(
                      width: 120,
                      child: CSOutlineButton(
                        onPressed: onPressedButton,
                        text: textButton!,
                      ),
                    )
                  : Container(
                      width: 135,
                      height: 55,
                      padding: const EdgeInsets.all(8),
                      child: CSOutlineButton(
                        onPressed: onPressedButton,
                        text: textButton!,
                        style: ButtonStyle(
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(
            top: CheckoutPage.pageSpacing,
          ),
          child: content,
        ),
      ],
    );
  }
}
