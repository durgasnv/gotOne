import 'package:intl/intl.dart';

/// Shared label helpers used by multiple screens.
String durLabel(int mins) {
  if (mins < 60) return '$mins min';
  if (mins < 1440) return '${mins ~/ 60} hr${mins ~/ 60 > 1 ? 's' : ''}';
  return '${mins ~/ 1440} day${mins ~/ 1440 > 1 ? 's' : ''}';
}

String timeLabel(DateTime dt) {
  final diff = dt.difference(DateTime.now());
  if (diff.inMinutes < 5) return 'Now';
  if (diff.inHours < 1) return 'in ${diff.inMinutes} min';
  if (diff.inHours < 24) return DateFormat('h:mm a').format(dt);
  return 'Today';
}
