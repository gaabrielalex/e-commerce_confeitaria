import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confeitaria_divine_cacau/util/styles/cs_text_styles.dart';
import 'package:flutter/material.dart';

class CsStreamBuilder extends StatefulWidget {
  final void Function()? streamOnHasNoData;
  final Stream<dynamic>? stream;
  final bool isStream;
  final Widget Function(AsyncSnapshot<dynamic>) contentBuilder;
  final Widget? streamHasNoDataContent;

  const CsStreamBuilder({
    super.key,
    this.streamOnHasNoData,
    this.stream,
    this.isStream = false,
    required this.contentBuilder,
    this.streamHasNoDataContent,
  });

  @override
  State<CsStreamBuilder> createState() => _CsStreamBuilderState();
}

class _CsStreamBuilderState extends State<CsStreamBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: widget.stream,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(
                  'Erro ao carregar os dados! Caso o erro persista, entre em contato com o suporte.',
                  textAlign: TextAlign.center,
                  style: CSTextSyles.alertText(context),
                ),
              ),
            );
          } else if (widget.isStream &&
              (!snapshot.hasData ||
                  snapshot.data == null ||
                  (snapshot.data is QuerySnapshot &&
                      snapshot.data.docs.isEmpty) ||
                  (snapshot.data is DocumentSnapshot &&
                      snapshot.data.exists == false))) {
            if (widget.streamOnHasNoData != null) {
              widget.streamOnHasNoData!.call();
            }
            return Center(
              child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: widget.streamHasNoDataContent ??
                      const CircularProgressIndicator()),
            );
          } else {
            return widget.contentBuilder.call(snapshot);
          }
        });
  }
}
