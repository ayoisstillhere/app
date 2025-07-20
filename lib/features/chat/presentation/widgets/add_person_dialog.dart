// Dialog widget for selecting a single person to add to call
import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../data/models/get_messages_response_model.dart';
import '../../domain/entities/get_messages_response_entity.dart';

class AddPersonDialog extends StatefulWidget {
  final List<Conversation> conversations;
  final UserEntity currentUser;
  final bool isLoading;
  final Function(String) onAddPerson; // Changed to accept single String
  final VoidCallback onRefresh;

  const AddPersonDialog({
    super.key,
    required this.conversations,
    required this.currentUser,
    required this.isLoading,
    required this.onAddPerson,
    required this.onRefresh,
  });

  @override
  State<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<AddPersonDialog> {
  String? _selectedConversationId; // Changed to single selection
  String _searchQuery = '';

  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return widget.conversations;

    return widget.conversations.where((conversation) {
      final isGroupChat = conversation.type == "GROUP";
      final name = isGroupChat
          ? (conversation.name ?? 'Group Chat')
          : conversation.participants
                .firstWhere(
                  (participant) =>
                      participant.user.username != widget.currentUser.username,
                  orElse: () => conversation.participants.first,
                )
                .user
                .fullName;

      return name!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Person to Call'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: 16),

            // Conversations list
            Expanded(
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredConversations.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No conversations available'
                              : 'No conversations match your search',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (widget.conversations.isEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: widget.onRefresh,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ],
                    )
                  : ListView.builder(
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _filteredConversations[index];
                        final isGroupChat = conversation.type == "GROUP";
                        final otherParticipant = isGroupChat
                            ? null
                            : conversation.participants.firstWhere(
                                (participant) =>
                                    participant.user.username !=
                                    widget.currentUser.username,
                                orElse: () =>
                                    conversation.participants.first
                                        as ParticipantModel,
                              );

                        final name = isGroupChat
                            ? (conversation.name ?? 'Group Chat')
                            : (otherParticipant?.user.fullName ??
                                  'Unknown User');

                        final image = isGroupChat
                            ? (conversation.groupImage ?? '')
                            : (otherParticipant?.user.profileImage ?? '');

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: image.isNotEmpty
                                ? NetworkImage(image)
                                : null,
                            child: image.isEmpty
                                ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                  )
                                : null,
                          ),
                          title: Text(name),
                          // subtitle: Text(
                          //   isGroupChat ? 'Group' : 'Direct message',
                          // ),
                          trailing: Radio<String>(
                            value: conversation.id,
                            groupValue: _selectedConversationId,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedConversationId = value;
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              _selectedConversationId = conversation.id;
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedConversationId == null
              ? null
              : () {
                  widget.onAddPerson(_selectedConversationId!);
                  Navigator.of(context).pop();
                },
          child: const Text('Add Person'),
        ),
      ],
    );
  }
}
