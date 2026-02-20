import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/domain/booking_model.dart';
import '../../../../core/providers/theme_mode_provider.dart';

final _studentBookingsCountProvider = StreamProvider.family<int, String>((ref, studentId) {
  return ref.read(firestoreRepositoryProvider).studentBookingsStream(studentId).map(
        (list) => list.where((b) => b.status == BookingStatus.pending || b.status == BookingStatus.accepted).length,
      );
});

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    final bookingCount = ref.watch(_studentBookingsCountProvider(user.uid)).valueOrNull ?? 0;
    final initial = (user.displayName ?? user.email).isNotEmpty ? (user.displayName ?? user.email)[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnTurn'),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => context.push('/student/chats')),
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {
              final mode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') ref.read(authServiceProvider).signOut();
            },
            itemBuilder: (_) => [const PopupMenuItem(value: 'logout', child: Text('Sign out'))],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(initial, style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${user.displayName ?? user.email}!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Find a tutor and start learning.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Quick actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionChip(icon: Icons.search, label: 'Find tutors', onTap: () => context.push('/student/search')),
              _ActionChip(icon: Icons.event_note, label: 'My bookings', onTap: () => context.push('/student/bookings')),
              _ActionChip(icon: Icons.chat_bubble_outline, label: 'Chats', onTap: () => context.push('/student/chats')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Menu', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.person_outline,
            title: 'My profile',
            subtitle: 'Edit your grade, subjects, and goals',
            onTap: () => context.push('/student/profile/edit'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.search,
            title: 'Find tutors',
            subtitle: 'Search by subject, price, and availability',
            onTap: () => context.push('/student/search'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            icon: Icons.event_note,
            title: 'My bookings',
            subtitle: bookingCount > 0 ? '$bookingCount upcoming session(s)' : 'View pending and past sessions',
            onTap: () => context.push('/student/bookings'),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 20, color: theme.colorScheme.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(icon, size: 28, color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
