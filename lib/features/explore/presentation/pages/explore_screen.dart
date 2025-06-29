import 'package:app/features/home/presentation/widgets/reply_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../widgets/follow_suggestions_list.dart';
import '../widgets/trending_topic.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isSearchQueried = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchFocused = false;
      _isSearchQueried = false;
    });
  }

  void _clearSearchResults() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchQueried = false;
      _isSearchFocused = false;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Add to recent searches if not already present
      if (!mockRecentSearches.contains(query)) {
        setState(() {
          mockRecentSearches.insert(0, query);
          // Keep only the last 10 searches
          if (mockRecentSearches.length > 10) {
            mockRecentSearches = mockRecentSearches.take(10).toList();
          }
        });
      }
      // Handle the search logic here
      print("Searching for: $query");
      setState(() {
        _isSearchQueried = true;
      });
    }
  }

  void _selectRecentSearch(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _clearRecentSearch(String search) {
    setState(() {
      mockRecentSearches.remove(search);
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      mockRecentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _isSearchQueried ? Container() : _buildSearchHeader(context),
              _isSearchFocused
                  ? _buildSearchView(context)
                  : _isSearchQueried
                  ? _buildSearchResultsView(context)
                  : _buildExploreView(context, dividerColor, iconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getProportionateScreenHeight(35)),
          Row(
            children: [
              Text(
                "Explore",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: getProportionateScreenHeight(20),
                ),
              ),
              Spacer(),
              if (_isSearchFocused) ...[
                SizedBox(width: getProportionateScreenWidth(12)),
                GestureDetector(
                  onTap: _cancelSearch,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(16)),
          TextFormField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onFieldSubmitted: _onSearchSubmitted,
            decoration: _buildExploreSearchFieldInputDecoration(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: getProportionateScreenHeight(12)),
        if (mockRecentSearches.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: getProportionateScreenHeight(15),
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllRecentSearches,
                  child: Text(
                    "Clear all",
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(16)),
          ...List.generate(
            mockRecentSearches.length,
            (index) =>
                _buildRecentSearchItem(context, mockRecentSearches[index]),
          ),
        ] else ...[
          Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(32)),
            child: Center(
              child: Text(
                "Try searching for people, topics, or keywords",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: getProportionateScreenHeight(16),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentSearchItem(BuildContext context, String search) {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    return ListTile(
      leading: Icon(
        Icons.history_toggle_off,
        color: Colors.grey,
        size: getProportionateScreenWidth(18),
      ),
      title: Text(
        search,
        style: TextStyle(fontSize: getProportionateScreenHeight(15)),
      ),
      trailing: GestureDetector(
        onTap: () => _clearRecentSearch(search),
        child: Icon(
          Icons.close,
          color: Colors.grey,
          size: getProportionateScreenWidth(18),
        ),
      ),
      onTap: () => _selectRecentSearch(search),
      shape: Border(bottom: BorderSide(width: 1, color: dividerColor)),
    );
  }

  Widget _buildExploreView(
    BuildContext context,
    Color dividerColor,
    Color iconColor,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: getProportionateScreenHeight(8)),
          FollowSuggestionsList(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Text(
              "Trending",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: getProportionateScreenHeight(16),
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(23)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var image in trendingImages)
                  Container(
                    width: getProportionateScreenWidth(159),
                    height: getProportionateScreenHeight(161),
                    margin: EdgeInsets.only(
                      right: getProportionateScreenWidth(10),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        getProportionateScreenWidth(10),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(52)),
          ReplyCard(
            dividerColor: dividerColor,
            iconColor: iconColor,
            replyerName: mockReplies.first["userName"],
            replyerHandle: mockReplies.first["handle"],
            imageUrl: mockReplies.first["userImage"],
            postTime: mockReplies.first["replyTime"],
            likes: mockReplies.first["likes"],
            comments: mockReplies.first["comments"],
            reposts: mockReplies.first["reposts"],
            bookmarks: mockReplies.first["bookmarks"],
            content: mockReplies.first["content"],
            authorHandle: mockReplies.first["parentPostId"],
          ),
          SizedBox(height: getProportionateScreenHeight(54)),
          Padding(
            padding: EdgeInsets.only(left: getProportionateScreenWidth(19)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                mockTrendingTopics.length,
                (index) => Column(
                  children: [
                    TrendingTopic(
                      topic: mockTrendingTopics[index]["topic"],
                      postNumber: mockTrendingTopics[index]["postNumber"],
                    ),
                    SizedBox(height: getProportionateScreenWidth(16)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(87)),
        ],
      ),
    );
  }

  Widget _buildSearchResultsView(BuildContext context) {
    return Center(child: Text("Search Results"));
  }

  InputDecoration _buildExploreSearchFieldInputDecoration(
    BuildContext context,
  ) {
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
