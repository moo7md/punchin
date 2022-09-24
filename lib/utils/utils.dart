import 'package:intl/intl.dart';

bool isEmpty(String? value) => value == null || value.isEmpty;
String formatDateTime(DateTime dateTime) => DateFormat.yMEd().add_jms().format(dateTime);