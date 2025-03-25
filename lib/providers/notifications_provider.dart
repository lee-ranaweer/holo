import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final DateTime time;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]);

  void addNotification(NotificationItem notification) {
    // Prepend the new notification so the most recent appears at the top.
    state = [notification, ...state];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
      (ref) => NotificationsNotifier(),
    );
