import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../bookings/domain/booking_model.dart';
import '../../../reviews/domain/review_model.dart';

class StudentBookingsScreen extends ConsumerWidget {
  const StudentBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Not signed in')));
    final repo = ref.watch(firestoreRepositoryProvider);
    final bookingsAsync = ref.watch(_studentBookingsProvider(uid));
    return Scaffold(
      appBar: AppBar(title: const Text('My bookings')),
      body: bookingsAsync.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No bookings yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _BookingCard(booking: list[i], onLeaveReview: () => _showReviewDialog(context, ref, list[i])),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static Future<void> _showReviewDialog(BuildContext context, WidgetRef ref, Booking booking) async {
    if (booking.status != BookingStatus.completed) return;
    final result = await showDialog<({int rating, String? comment})>(context: context, builder: (c) {
      int rating = 5;
      final commentController = TextEditingController();
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Leave a review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  icon: Icon((i + 1) <= rating ? Icons.star : Icons.star_border),
                  onPressed: () => setState(() => rating = i + 1),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Comment (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(c, (rating: rating, comment: commentController.text.trim().isEmpty ? null : commentController.text.trim())),
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    });
    if (result == null) return;
    final repo = ref.read(firestoreRepositoryProvider);
    await repo.addReview(Review(
      id: const Uuid().v4(),
      bookingId: booking.id,
      tutorId: booking.tutorId,
      studentId: booking.studentId,
      rating: result.rating,
      comment: result.comment,
      createdAt: DateTime.now(),
    ));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted')));
  }
}

final _studentBookingsProvider = StreamProvider.family<List<Booking>, String>((ref, studentId) {
  return ref.read(firestoreRepositoryProvider).studentBookingsStream(studentId);
});

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onLeaveReview;

  const _BookingCard({required this.booking, this.onLeaveReview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            const SizedBox(height: 8),
            Text('${DateFormat.yMMMd().format(booking.scheduledAt)} • \$${booking.agreedPrice.toStringAsFixed(0)}'),
            if (booking.videoMeetingLink != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join session'),
                  onPressed: () {},
                ),
              ),
            if (booking.status == BookingStatus.completed && onLeaveReview != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Leave review'),
                  onPressed: onLeaveReview,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
