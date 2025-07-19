import 'package:app/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../constants.dart';
import '../../../../size_config.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<BlockedUser> blockedUsers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final token = await AuthManager.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/user/blocked-users'),
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersData = data['blockedUsers'] ?? data ?? [];

        setState(() {
          blockedUsers = usersData
              .map((user) => BlockedUser.fromJson(user))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load blocked users';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> unblockUser(String userId, int index) async {
    try {
      final token = await AuthManager.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/user/unblock/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          blockedUsers.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unblock user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
          "Blocked Users",
          style: TextStyle(
            fontSize: getProportionateScreenHeight(24),
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
      body: RefreshIndicator(onRefresh: fetchBlockedUsers, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final dividerColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
        ? kGreyInputFillDark
        : kGreyInputBorder;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: getProportionateScreenHeight(64),
              color: Colors.grey,
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: getProportionateScreenHeight(16),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            ElevatedButton(
              onPressed: fetchBlockedUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: getProportionateScreenHeight(64),
              color: Colors.grey,
            ),
            SizedBox(height: getProportionateScreenHeight(16)),
            Text(
              "No blocked users",
              style: TextStyle(
                fontSize: getProportionateScreenHeight(18),
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(8)),
            Text(
              "Users you block will appear here",
              style: TextStyle(
                fontSize: getProportionateScreenHeight(14),
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(16)),
      itemCount: blockedUsers.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: dividerColor,
        indent: getProportionateScreenWidth(72),
      ),
      itemBuilder: (context, index) {
        final user = blockedUsers[index];
        return BlockedUserTile(
          user: user,
          onUnblock: () => _showUnblockDialog(user.id, index),
        );
      },
    );
  }

  void _showUnblockDialog(String userId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: Text(
            'Are you sure you want to unblock ${blockedUsers[index].username}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                unblockUser(userId, index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Unblock'),
            ),
          ],
        );
      },
    );
  }
}

class BlockedUserTile extends StatelessWidget {
  final BlockedUser user;
  final VoidCallback onUnblock;

  const BlockedUserTile({
    super.key,
    required this.user,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(8),
      ),
      leading: CircleAvatar(
        radius: getProportionateScreenWidth(24),
        backgroundImage: user.profileImageUrl != null
            ? NetworkImage(user.profileImageUrl!)
            : null,
        child: user.profileImageUrl == null
            ? Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: getProportionateScreenHeight(18),
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        user.fullName ?? user.username,
        style: TextStyle(
          fontSize: getProportionateScreenHeight(16),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: user.fullName != null
          ? Text(
              '@${user.username}',
              style: TextStyle(
                fontSize: getProportionateScreenHeight(14),
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: OutlinedButton(
        onPressed: onUnblock,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          foregroundColor: Colors.red,
          minimumSize: Size(
            getProportionateScreenWidth(80),
            getProportionateScreenHeight(32),
          ),
        ),
        child: Text(
          'Unblock',
          style: TextStyle(
            fontSize: getProportionateScreenHeight(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class BlockedUser {
  final String id;
  final String username;
  final String? fullName;
  final String? profileImageUrl;
  final String? bio;

  BlockedUser({
    required this.id,
    required this.username,
    this.fullName,
    this.profileImageUrl,
    this.bio,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? json['full_name'],
      profileImageUrl: json['profileImage'],
      bio: json['bio'] ?? json['description'],
    );
  }
}
