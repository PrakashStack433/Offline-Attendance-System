import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String formatTime(DateTime time) => DateFormat('HH:mm').format(time);

String formatDateTime(DateTime dt) => DateFormat('yyyy-MM-dd HH:mm').format(dt);

String formatDateDisplay(DateTime date) => DateFormat('dd MMM yyyy').format(date);

String formatDateFull(DateTime date) => DateFormat('EEEE, dd MMMM yyyy').format(date);

DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime endOfDay(DateTime date) => startOfDay(date).add(const Duration(days: 1));
