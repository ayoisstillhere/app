import 'package:app/features/home/domain/entities/explore_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class FollowSuggestionsList extends StatelessWidget {
  const FollowSuggestionsList({super.key, required this.suggestedAccounts});
  final List<SuggestedAccount> suggestedAccounts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(25),
        right: getProportionateScreenWidth(18),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestedAccounts.length,
        itemBuilder: (context, index) {
          return FollowSuggestion(
            image: suggestedAccounts[index].profileImage,
            name: suggestedAccounts[index].fullName,
            followerCount: suggestedAccounts[index].followersCount,
            handle: suggestedAccounts[index].username,
            bio: suggestedAccounts[index].bio,
          );
        },
      ),
    );
  }
}

class FollowSuggestion extends StatelessWidget {
  const FollowSuggestion({
    required this.image,
    required this.name,
    required this.followerCount,
    required this.handle,
    required this.bio,
    super.key,
  });

  final String image;
  final String name;
  final int followerCount;
  final String handle;
  final String bio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  height: getProportionateScreenHeight(25),
                  width: getProportionateScreenWidth(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: image.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(10)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: getProportionateScreenHeight(13),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '@$handle',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: getProportionateScreenHeight(13),
                      color: kGreyHandleText,
                    ),
                  ),
                ],
              ),
              SizedBox(width: getProportionateScreenWidth(7)),
              Text(
                NumberFormat.compact().format(followerCount),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: getProportionateScreenHeight(13),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () {},
                child: Container(
                  height: getProportionateScreenHeight(37),
                  width: getProportionateScreenWidth(90),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Follow",
                      style: TextStyle(
                        fontSize: 12,
                        color: kBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(7)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(40),
            ),
            child: Text(bio),
          ),
        ],
      ),
    );
  }
}
