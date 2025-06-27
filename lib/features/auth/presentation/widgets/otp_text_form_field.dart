import 'package:app/size_config.dart';
import 'package:flutter/material.dart';

class OtpTextFormField extends StatelessWidget {
  const OtpTextFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.displayMedium,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getProportionateScreenWidth(10),
            ),
          ),
        ),
      ),
    );
  }
}
