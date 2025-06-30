import 'package:app/constants.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';

// ignore: must_be_immutable
class ChatSuggestionTile extends StatefulWidget {
  ChatSuggestionTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.handle,
    required this.isSelected,
    this.showCheckbox = false,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String handle;
  bool isSelected;
  final bool showCheckbox;

  @override
  State<ChatSuggestionTile> createState() => _ChatSuggestionTileState();
}

class _ChatSuggestionTileState extends State<ChatSuggestionTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: widget.dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            height: getProportionateScreenHeight(56),
            width: getProportionateScreenWidth(56),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(widget.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: getProportionateScreenWidth(16)),
          SizedBox(
            height: getProportionateScreenHeight(47),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    SizedBox(
                      width: getProportionateScreenWidth(228),
                      child: Text(
                        '@${widget.handle}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: getProportionateScreenHeight(12),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Spacer(),
          if (widget.showCheckbox)
            Checkbox(
              value: widget.isSelected,
              onChanged: (value) {
                setState(() {
                  widget.isSelected = value!;
                });
              },
              checkColor: Colors.white,
              activeColor: kAccentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  getProportionateScreenWidth(5),
                ),
              ),
              side: BorderSide(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? kGreyInputFillDark
                    : kLightPurple,
                width: 1.0,
              ),
            ),
        ],
      ),
    );
  }
}
