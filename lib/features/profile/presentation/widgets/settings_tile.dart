import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../size_config.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.dividerColor,
    required this.settings,
    required this.iconColor,
  });

  final Color dividerColor;
  final Color iconColor;
  final Map<String, dynamic> settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(8)),
      margin: EdgeInsets.only(
        left: getProportionateScreenWidth(21),
        right: getProportionateScreenWidth(19),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            settings["icon"],
            width: getProportionateScreenWidth(24),
            height: getProportionateScreenHeight(24),
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: getProportionateScreenWidth(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings["title"],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: getProportionateScreenHeight(15),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
              ...settings["subItems"]
                  .map<Widget>(
                    (item) => Padding(
                      padding: EdgeInsets.only(
                        bottom: getProportionateScreenHeight(9),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: getProportionateScreenHeight(12),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ],
      ),
    );
  }
}
