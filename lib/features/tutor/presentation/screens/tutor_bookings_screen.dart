import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/domain/booking_model.dart';

class TutorBookingsScreen extends ConsumerWidget {
  const TutorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Not signed in')));
    final bookingsAsync = ref.watch(_tutorBookingsProvider(uid));
    return Scaffold(
      appBar: AppBar(title: const Text('Booking requests')),
      body: bookingsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No requests yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _TutorBookingCard(booking: list[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

final _tutorBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, tutorId) {
  return ref.read(firestoreRepositoryProvider).tutorBookingsStream(tutorId);
});

class _TutorBookingCard extends ConsumerWidget {
  final Booking booking;

  const _TutorBookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(firestoreRepositoryProvider);
    final statusColor = switch (booking.status) {
      BookingStatus.pending => Colors.orange,
      BookingStatus.accepted => Colors.green,
      BookingStatus.completed => Colors.blue,
      BookingStatus.cancelled => Colors.grey,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.subject, style: theme.textTheme.titleMedium),
                Chip(
                  label: Text(booking.status.name, style: TextStyle(color: statusColor)),
                  backgroundColor: statusColor.withValues(alpha: 0.2),
                ),
              ],
            ),
            Text('${DateFormat.yMMMd().format(booking.scheduledAt)} • \$${booking.agreedPrice.toStringAsFixed(0)}'),
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await repo.updateBookingStatus(booking.id, BookingStatus.accepted);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accepted')));
                    },
                    child: const Text('Accept'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await repo.updateBookingStatus(booking.id, BookingStatus.cancelled);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
            if (booking.status == BookingStatus.accepted) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Add Zoom/Meet link'),
                onPressed: () async {
                  final link = await showDialog<String>(context: context, builder: (c) {
                    final tc = TextEditingController();
                    return AlertDialog(
                      title: const Text('Video meeting link'),
                      content: TextField(controller: tc, decoration: const InputDecoration(hintText: 'https://zoom.us/...')),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(c, tc.text), child: const Text('Save')),
                      ],
                    );
                  });
                  if (link != null && link.isNotEmpty) {
                    await repo.setBookingVideoLink(booking.id, link);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link saved')));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
