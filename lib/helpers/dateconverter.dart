import 'package:intl/intl.dart';

String convertDate(String date) {
  int intDate = int.parse(date);
  //final format = DateFormat("yyyy-MM-dd hh:mm");
  final format = DateFormat.yMd().add_jms();
  return format
      .format(DateTime.fromMillisecondsSinceEpoch(intDate * 1000))
      .toString();
}
