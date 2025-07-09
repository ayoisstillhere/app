import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/domain/entities/explore_response_entity.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class FollowSuggestionsList extends StatelessWidget {
  const FollowSuggestionsList({
    super.key,
    required this.suggestedAccounts,
    required this.currentUser,
  });
  final List<SuggestedAccount> suggestedAccounts;
  final UserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(25),
        right: getProportionateScreenWidth(18),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestedAccounts.length,
        itemBuilder: (context, index) {
          return FollowSuggestion(
            image: suggestedAccounts[index].profileImage,
            name: suggestedAccounts[index].fullName,
            followerCount: suggestedAccounts[index].followersCount,
            handle: suggestedAccounts[index].username,
            bio: suggestedAccounts[index].bio,
            currentUser: currentUser,
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
    required this.currentUser,
  });

  final String image;
  final String name;
  final int followerCount;
  final String handle;
  final String bio;
  final UserEntity currentUser;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              isVerified: true,
              userName: handle,
              currentUser: currentUser,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: getProportionateScreenHeight(26)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: getProportionateScreenHeight(25),
                  width: getProportionateScreenWidth(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: image.isEmpty
                        ? null
                        : DecorationImage(
                            image: image.isEmpty
                                ? NetworkImage(defaultAvatar)
                                : NetworkImage(image),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "User" : name,
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
                  '${NumberFormat.compact().format(followerCount)} Followers',
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
                horizontal: getProportionateScreenWidth(35),
              ),
              child: Text(bio),
            ),
          ],
        ),
      ),
    );
  }
}
