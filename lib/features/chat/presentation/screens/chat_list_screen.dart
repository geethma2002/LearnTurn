import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/domain/user_model.dart';
import '../../domain/message_model.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Not signed in')));
    final chatsAsync = ref.watch(_chatsProvider(uid));
    final isStudent = ref.watch(authStateProvider).valueOrNull?.role.isStudent ?? true;
    final basePath = isStudent ? '/student' : '/tutor';
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No chats yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final chat = list[i];
                  final otherId = chat.participantIds.firstWhere((id) => id != uid, orElse: () => '');
                  return ListTile(
                    title: Text('Chat with ${otherId.substring(0, otherId.length > 8 ? 8 : otherId.length)}...'),
                    subtitle: Text(chat.lastMessageText ?? 'No messages'),
                    trailing: chat.lastMessageAt != null ? Text(DateFormat.Md().format(chat.lastMessageAt!)) : null,
                    onTap: () => context.push('$basePath/chat/${chat.id}'),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

final _chatsProvider = StreamProvider.family<List<ChatRoom>, String>((ref, userId) {
  return ref.read(firestoreRepositoryProvider).userChatsStream(userId);
});
