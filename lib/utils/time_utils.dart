import 'package:timeago/timeago.dart' as timeago;

String formatTime(int unixTimestamp) {
  final date =
      DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  return timeago.format(date);
}
