import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({super.key});

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(16),
      height: getProportionateScreenHeight(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kWhite, // Background color
          border: Border.all(
            color: kGreyInputBorder, // Border color
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(
            getProportionateScreenWidth(4),
          ), // Corner radius
        ),
        child: Checkbox(
          value: isChecked,
          onChanged: (bool? value) {
            setState(() {
              isChecked = value!;
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(getProportionateScreenWidth(4)),
            ),
          ),
        ),
      ),
    );
  }
}
