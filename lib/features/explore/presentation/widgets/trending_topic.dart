import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class TrendingTopic extends StatelessWidget {
  final String topic;
  final int postNumber;

  const TrendingTopic({
    super.key,
    required this.topic,
    required this.postNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          topic,
          style: TextStyle(
            fontSize: getProportionateScreenHeight(16),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(4)),
        Text(
          "${NumberFormat.compact().format(postNumber)} posts",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(14),
            color: kGreyHandleText,
          ),
        ),
      ],
    );
  }
}
