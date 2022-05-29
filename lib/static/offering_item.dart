import 'package:intl/intl.dart';

class OfferingItem {
  String id_order, client_name, at;
  String? job_title;

  OfferingItem(this.id_order, this.job_title, this.client_name, this.at) {
    if (this.at.isNotEmpty) {
      DateTime dt = DateTime.parse(this.at);
      this.at = DateFormat.yMMMMd('en_US').format(dt);
    }

    this.job_title = toBeginningOfSentenceCase(this.job_title);
  }
}
