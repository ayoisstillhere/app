import 'package:app/constants.dart';
import 'package:flutter/material.dart';

import '../../../../size_config.dart';

class ChatSuggestionTile extends StatefulWidget {
  const ChatSuggestionTile({
    super.key,
    required this.dividerColor,
    required this.image,
    required this.name,
    required this.handle,
    required this.isSelected,
    this.showCheckbox = false,
    this.onSelectionChanged,
  });

  final Color dividerColor;
  final String image;
  final String name;
  final String handle;
  final bool isSelected;
  final bool showCheckbox;
  final Function(bool)? onSelectionChanged;

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
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(16),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(4)),
                Text(
                  '@${widget.handle}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: getProportionateScreenHeight(12),
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          if (widget.showCheckbox)
            Checkbox(
              value: widget.isSelected,
              onChanged: (value) {
                if (widget.onSelectionChanged != null) {
                  widget.onSelectionChanged!(value ?? false);
                }
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
