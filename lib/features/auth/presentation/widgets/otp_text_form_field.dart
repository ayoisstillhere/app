import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../size_config.dart';

class OtpTextFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final TextEditingController? controller;

  const OtpTextFormField({
    super.key,
    this.focusNode,
    this.nextFocusNode,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(50),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(10),
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.length == 1 && nextFocusNode != null) {
            nextFocusNode!.requestFocus();
          }
        },
      ),
    );
  }
}
