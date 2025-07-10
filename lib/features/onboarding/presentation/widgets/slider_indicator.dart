import 'package:flutter/material.dart';

import 'package:app/constants.dart';

import '../../../../size_config.dart';

class SliderIndicator extends StatelessWidget {
  const SliderIndicator({super.key, required this.currentPage});
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildDot(0, context),
        SizedBox(width: getProportionateScreenWidth(9)),
        _buildDot(1, context),
        SizedBox(width: getProportionateScreenWidth(9)),
        _buildDot(2, context),
      ],
    );
  }

  Container _buildDot(int index, BuildContext context) {
    return currentPage == index
        ? Container(
            height: getProportionateScreenHeight(8),
            width: getProportionateScreenWidth(8),
            decoration: BoxDecoration(
              color: kAccentColor,
              shape: BoxShape.circle,
            ),
          )
        : Container(
            height: getProportionateScreenHeight(8),
            width: getProportionateScreenWidth(8),
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          );
  }
}
