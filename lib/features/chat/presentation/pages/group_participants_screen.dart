import 'package:flutter/material.dart';

import 'package:app/features/chat/domain/entities/get_messages_response_entity.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/group_participants_tile.dart';

class GroupParticipantsScreen extends StatefulWidget {
  const GroupParticipantsScreen({
    super.key,
    required this.participants,
    required this.conversationId,
  });
  final List<Participant> participants;
  final String conversationId;

  @override
  State<GroupParticipantsScreen> createState() =>
      _GroupParticipantsScreenState();
}

class _GroupParticipantsScreenState extends State<GroupParticipantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Search functionality is handled by _onSearchChanged
    }
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Group Participants",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(20),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(getProportionateScreenHeight(20)),
          child: Container(
            width: double.infinity,
            height: 1,
            color: dividerColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: getProportionateScreenWidth(16),
          ),
          child: Column(
            children: [
              SizedBox(height: getProportionateScreenHeight(17)),
              TextFormField(
                controller: _searchController,
                onFieldSubmitted: _onSearchSubmitted,
                decoration: _buildSearchFieldInputDecoration(context),
              ),
              SizedBox(height: getProportionateScreenHeight(31)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.participants.length,
                itemBuilder: (context, index) {
                  final participant = widget.participants[index];
                  return GroupParticipantsTile(
                    dividerColor: dividerColor,
                    participant: participant,
                    conversationId: widget.conversationId,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildSearchFieldInputDecoration(BuildContext context) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(30)),
        borderSide: BorderSide(
          color: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? kGreyDarkInputBorder
              : kGreyInputBorder,
        ),
      ),
      fillColor: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? kGreySearchInput
          : null,
      filled: MediaQuery.of(context).platformBrightness == Brightness.dark,
      prefixIcon: Padding(
        padding: EdgeInsets.all(getProportionateScreenHeight(14)),
        child: SvgPicture.asset(
          "assets/icons/search.svg",
          colorFilter: ColorFilter.mode(
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? kGreyDarkInputBorder
                : kGreyInputBorder,
            BlendMode.srcIn,
          ),
          width: getProportionateScreenWidth(14),
          height: getProportionateScreenHeight(14),
        ),
      ),
      hintText: "Search",
    );
  }
}
