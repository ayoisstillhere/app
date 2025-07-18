import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/home/data/models/explore_response_model.dart';
import 'package:app/features/home/domain/entities/explore_response_entity.dart';
import 'package:app/features/home/domain/entities/search_response_entity.dart';
import 'package:app/services/auth_manager.dart';

import '../../../../constants.dart';
import '../../../../size_config.dart';
import '../../../home/data/models/search_response_model.dart';
import '../../../home/presentation/widgets/post_Card.dart';
import '../widgets/follow_suggestions_list.dart';
import '../widgets/trending_topic.dart';

// ignore: must_be_immutable
class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key, required this.currentUser});
  VoidCallback? onExploreButtonPressed;
  final UserEntity currentUser;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isSearchQueried = false;
  late TabController controller;
  ExploreResponseEntity? exploreResponse;
  bool isExploreLoaded = false;
  SearchResponseEntity? searchResponse;
  List<String> recentSearches = [];
  bool _isResultsLoaded = false;

  // Pagination variables
  bool _isLoadingMore = false;
  bool _hasMoreResults = true;
  int _currentPage = 1;
  final int _pageSize = 20; // Adjust based on your API
  String _currentQuery = '';

  // ScrollControllers for each tab
  late ScrollController _topScrollController;
  late ScrollController _recentScrollController;
  late ScrollController _mediaScrollController;
  late ScrollController _peopleScrollController;

  // Load recent searches from SharedPreferences when the screen initializes
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searchesJson = prefs.getString('recent_searches');

    if (searchesJson != null) {
      setState(() {
        recentSearches = List<String>.from(jsonDecode(searchesJson));
      });
    }
  }

  // Save recent searches to SharedPreferences
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', jsonEncode(recentSearches));
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    controller = TabController(length: 4, vsync: this);
    widget.onExploreButtonPressed = resetExplore;
    _loadRecentSearches();
    _getExploreContent();

    // Initialize scroll controllers
    _topScrollController = ScrollController();
    _recentScrollController = ScrollController();
    _mediaScrollController = ScrollController();
    _peopleScrollController = ScrollController();

    // Add scroll listeners for pagination
    _topScrollController.addListener(() => _onScroll(_topScrollController));
    _recentScrollController.addListener(
      () => _onScroll(_recentScrollController),
    );
    _mediaScrollController.addListener(() => _onScroll(_mediaScrollController));
    _peopleScrollController.addListener(
      () => _onScroll(_peopleScrollController),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    controller.dispose();
    _topScrollController.dispose();
    _recentScrollController.dispose();
    _mediaScrollController.dispose();
    _peopleScrollController.dispose();
    super.dispose();
  }

  void _onScroll(ScrollController scrollController) {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _loadMoreResults();
    }
  }

  void _onSearchFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void resetExplore() {
    if (!mounted) return;
    if (_isSearchFocused || _isSearchQueried) {
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        _isSearchFocused = false;
        _isSearchQueried = false;
        _resetPaginationState();
      });
    }
  }

  void _resetPaginationState() {
    _currentPage = 1;
    _hasMoreResults = true;
    _isLoadingMore = false;
    _currentQuery = '';
    searchResponse = null;
    _isResultsLoaded = false;
  }

  void _cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearchFocused = false;
      _isSearchQueried = false;
      _resetPaginationState();
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Add to recent searches if not already present
      if (!recentSearches.contains(query)) {
        setState(() {
          recentSearches.insert(0, query);
          // Keep only the last 10 searches
          if (recentSearches.length > 10) {
            recentSearches = recentSearches.take(10).toList();
          }
        });
        _saveRecentSearches();
      }

      // Reset pagination state for new search
      _resetPaginationState();
      _currentQuery = query;
      _getSearchResults(query);
    }
  }

  void _selectRecentSearch(String search) {
    _searchController.text = search;
    _onSearchSubmitted(search);
  }

  void _clearRecentSearch(String search) {
    setState(() {
      recentSearches.remove(search);
    });
    _saveRecentSearches();
  }

  void _clearAllRecentSearches() {
    setState(() {
      recentSearches.clear();
    });
    _saveRecentSearches();
  }

  Future<void> _getExploreContent() async {
    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/v1/search/explore"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      exploreResponse = ExploreResponseModel.fromJson(
        jsonDecode(response.body),
      );
      setState(() {
        isExploreLoaded = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _getSearchResults(
    String query, {
    bool isLoadMore = false,
  }) async {
    if (_isLoadingMore || (!_hasMoreResults && isLoadMore)) return;

    if (isLoadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isSearchQueried = true;
        _currentPage = 1;
      });
    }

    final token = await AuthManager.getToken();
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/v1/search?query=$query&page=$_currentPage&limit=$_pageSize",
      ),
      headers: {"Authorization": "Bearer $token"},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final newSearchResponse = SearchResponseModel.fromJson(
        jsonDecode(response.body),
      );

      setState(() {
        if (isLoadMore && searchResponse != null) {
          // Append new results to existing ones
          searchResponse = SearchResponseEntity(
            top: [...searchResponse!.top, ...newSearchResponse.top],
            recent: Media(
              posts: [
                ...searchResponse!.recent.posts,
                ...newSearchResponse.recent.posts,
              ],
              pagination: Pagination(
                page: searchResponse!.recent.pagination.page,
                limit: searchResponse!.recent.pagination.limit,
                hasMore: searchResponse!.recent.pagination.hasMore,
              ),
            ),
            media: Media(
              posts: [
                ...searchResponse!.media.posts,
                ...newSearchResponse.media.posts,
              ],
              pagination: Pagination(
                page: searchResponse!.media.pagination.page,
                limit: searchResponse!.media.pagination.limit,
                hasMore: searchResponse!.media.pagination.hasMore,
              ),
            ),
            people: People(
              users: [
                ...searchResponse!.people.users,
                ...newSearchResponse.people.users,
              ],
              pagination: Pagination(
                page: searchResponse!.people.pagination.page,
                limit: searchResponse!.people.pagination.limit,
                hasMore: searchResponse!.people.pagination.hasMore,
              ),
            ),
            everything: Everything(
              users: [
                ...searchResponse!.everything.users,
                ...newSearchResponse.everything.users,
              ],
              posts: [
                ...searchResponse!.everything.posts,
                ...newSearchResponse.everything.posts,
              ],
              keywords: [
                ...searchResponse!.everything.keywords,
                ...newSearchResponse.everything.keywords,
              ],
              pagination: Pagination(
                page: searchResponse!.everything.pagination.page,
                limit: searchResponse!.everything.pagination.limit,
                hasMore: searchResponse!.everything.pagination.hasMore,
              ),
            ),
          );
        } else {
          // First load or new search
          searchResponse = newSearchResponse;
        }

        _isResultsLoaded = true;
        _isLoadingMore = false;
        _currentPage++;

        // Check if there are more results (adjust this logic based on your API response)
        // This assumes your API returns fewer items than requested when there are no more results
        _hasMoreResults =
            newSearchResponse.top.length == _pageSize ||
            newSearchResponse.recent.posts.length == _pageSize ||
            newSearchResponse.media.posts.length == _pageSize ||
            newSearchResponse.people.users.length == _pageSize;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            jsonDecode(
              response.body,
            )['message'].toString().replaceAll(RegExp(r'\[|\]'), ''),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Future<void> _loadMoreResults() async {
    if (_currentQuery.isNotEmpty && !_isLoadingMore && _hasMoreResults) {
      await _getSearchResults(_currentQuery, isLoadMore: true);
    }
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
        child: _isSearchQueried
            ? _buildSearchResultsView(context)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSearchHeader(context),
                    _isSearchFocused
                        ? _buildSearchView(context)
                        : _buildExploreView(context, dividerColor, iconColor),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(16),
        right: getProportionateScreenWidth(16),
        bottom: getProportionateScreenHeight(16),
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
        if (recentSearches.isNotEmpty) ...[
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
            recentSearches.length,
            (index) => _buildRecentSearchItem(context, recentSearches[index]),
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
    return isExploreLoaded
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getProportionateScreenHeight(8)),
                FollowSuggestionsList(
                  suggestedAccounts: exploreResponse!.suggestedAccounts,
                  currentUser: widget.currentUser,
                ),
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
                exploreResponse!.trending[0].media.isEmpty
                    ? Container()
                    : SizedBox(height: getProportionateScreenHeight(23)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var item in exploreResponse!.trending)
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
                              image: item.media.isEmpty
                                  ? NetworkImage(defaultAvatar)
                                  : NetworkImage(item.media[0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      exploreResponse!.trending.length,
                      (index) => PostCard(
                        dividerColor: dividerColor,
                        iconColor: iconColor,
                        imageUrl: exploreResponse!
                            .trending[index]
                            .author
                            .profileImage,
                        postTime: exploreResponse!.trending[index].createdAt,
                        likes: exploreResponse!.trending[index].count.likes,
                        comments:
                            exploreResponse!.trending[index].count.comments,
                        reposts: exploreResponse!.trending[index].count.reposts,
                        bookmarks: exploreResponse!.trending[index].count.saves,
                        content: exploreResponse!.trending[index].content,
                        authorHandle:
                            exploreResponse!.trending[index].author.username,
                        authorName:
                            exploreResponse!.trending[index].author.fullName,
                        pictures: exploreResponse!.trending[index].media,
                        forSearch: true,
                        currentUser: widget.currentUser,
                        postId: exploreResponse!.trending[index].id,
                        isLiked: false,
                        isReposted: false,
                        isSaved: false,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(8)),
                Padding(
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(19),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      exploreResponse!.popularKeywords.length,
                      (index) => Column(
                        children: [
                          TrendingTopic(
                            topic:
                                exploreResponse!.popularKeywords[index].keyword,
                            postNumber: exploreResponse!
                                .popularKeywords[index]
                                .postsCount,
                            onTap: () {
                              _searchController.text = exploreResponse!
                                  .popularKeywords[index]
                                  .keyword;
                              _onSearchSubmitted(
                                exploreResponse!.popularKeywords[index].keyword,
                              );
                            },
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
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildSearchResultsView(BuildContext context) {
    final iconColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kWhite
        : kBlack;
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    List<SuggestedAccount> suggestedAccounts = [];
    if (searchResponse != null) {
      for (var user in searchResponse!.people.users) {
        suggestedAccounts.add(
          SuggestedAccount(
            user.username,
            user.fullName,
            user.bio,
            user.profileImage,
            user.followersCount,
          ),
        );
      }
    }

    return Column(
      children: [
        SizedBox(
          height: getProportionateScreenHeight(113),
          child: AppBar(
            leading: InkWell(
              onTap: () {
                _cancelSearch();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: getProportionateScreenHeight(12),
                ),
                child: SvgPicture.asset(
                  "assets/icons/back_button.svg",
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
            title: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode, // Add this line
              onFieldSubmitted: _onSearchSubmitted, // Add this line
              onChanged: (value) {
                // Add this callback for real-time search (optional)
                // You can implement real-time search here if needed
                // For now, we'll just update on submission
              },
              decoration: _buildExploreSearchFieldInputDecoration(context),
            ),
            bottom: TabBar(
              controller: controller,
              indicatorColor: kLightPurple,
              dividerColor: dividerColor,
              labelStyle: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
              unselectedLabelStyle: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
              tabs: [
                Tab(
                  child: SizedBox(
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("Top")),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("Recent")),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("Media")),
                  ),
                ),
                Tab(
                  child: SizedBox(
                    width: getProportionateScreenWidth(143),
                    child: Center(child: Text("People")),
                  ),
                ),
              ],
              indicatorSize: TabBarIndicatorSize.label,
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  right: getProportionateScreenWidth(22),
                ),
                child: SizedBox(
                  height: getProportionateScreenHeight(24),
                  width: getProportionateScreenWidth(24),
                  child: InkWell(
                    onTap: () {},
                    child: SvgPicture.asset(
                      "assets/icons/more-vertical.svg",
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Wrap TabBarView with Expanded to give it bounded height
        Expanded(
          child: _isResultsLoaded
              ? TabBarView(
                  controller: controller,
                  children: [
                    _buildTopTabView(dividerColor, iconColor),
                    _buildRecentTabView(dividerColor, iconColor),
                    _buildMediaTabView(dividerColor, iconColor),
                    _buildPeopleTabView(),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildTopTabView(Color dividerColor, Color iconColor) {
    return ListView.builder(
      controller: _topScrollController,
      itemCount: searchResponse!.top.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchResponse!.top.length) {
          return _buildLoadingIndicator();
        }

        var item = searchResponse!.top[index];
        return GestureDetector(
          onTap: () {},
          child: item.type == "post"
              ? PostCard(
                  dividerColor: dividerColor,
                  iconColor: iconColor,
                  authorName: item.data.fullName!,
                  authorHandle: item.data.authorUsername!,
                  imageUrl: item.data.profileImage!,
                  postTime: item.data.createdAt!,
                  likes: item.data.likesCount!,
                  comments: item.data.commentsCount!,
                  reposts: item.data.repostsCount!,
                  bookmarks: item.data.savesCount!,
                  content: item.data.content!,
                  pictures: item.data.media!,
                  currentUser: widget.currentUser,
                  postId: item.data.id!,
                  isLiked: item.data.isLiked!,
                  isReposted: item.data.isReposted!,
                  isSaved: item.data.isSaved!,
                )
              : Container(),
        );
      },
    );
  }

  Widget _buildRecentTabView(Color dividerColor, Color iconColor) {
    return ListView.builder(
      controller: _recentScrollController,
      itemCount: searchResponse!.recent.posts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchResponse!.recent.posts.length) {
          return _buildLoadingIndicator();
        }

        final item = searchResponse!.recent.posts[index];
        return GestureDetector(
          onTap: () {},
          child: PostCard(
            dividerColor: dividerColor,
            iconColor: iconColor,
            authorName: item.fullName,
            authorHandle: item.authorUsername,
            imageUrl: item.profileImage,
            postTime: item.createdAt,
            likes: item.likesCount,
            comments: item.commentsCount,
            reposts: item.repostsCount,
            bookmarks: item.savesCount,
            content: item.content,
            pictures: item.media,
            currentUser: widget.currentUser,
            postId: item.id,
            isLiked: item.isLiked,
            isReposted: item.isReposted,
            isSaved: item.isSaved,
          ),
        );
      },
    );
  }

  Widget _buildMediaTabView(Color dividerColor, Color iconColor) {
    return ListView.builder(
      controller: _mediaScrollController,
      itemCount: searchResponse!.media.posts.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchResponse!.media.posts.length) {
          return _buildLoadingIndicator();
        }

        final item = searchResponse!.media.posts[index];
        return GestureDetector(
          onTap: () {},
          child: PostCard(
            dividerColor: dividerColor,
            iconColor: iconColor,
            authorName: item.fullName,
            authorHandle: item.authorUsername,
            imageUrl: item.profileImage,
            postTime: item.createdAt,
            likes: item.likesCount,
            comments: item.commentsCount,
            reposts: item.repostsCount,
            bookmarks: item.savesCount,
            content: item.content,
            pictures: item.media,
            currentUser: widget.currentUser,
            postId: item.id,
            isLiked: item.isLiked,
            isReposted: item.isReposted,
            isSaved: item.isSaved,
          ),
        );
      },
    );
  }

  Widget _buildPeopleTabView() {
    List<SuggestedAccount> suggestedAccounts = [];
    for (var user in searchResponse!.people.users) {
      suggestedAccounts.add(
        SuggestedAccount(
          user.username,
          user.fullName,
          user.bio,
          user.profileImage,
          user.followersCount,
        ),
      );
    }

    return ListView.builder(
      controller: _peopleScrollController,
      itemCount: 1 + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 1) {
          return _buildLoadingIndicator();
        }

        return Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            FollowSuggestionsList(
              suggestedAccounts: suggestedAccounts,
              currentUser: widget.currentUser,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(kLightPurple),
        ),
      ),
    );
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
