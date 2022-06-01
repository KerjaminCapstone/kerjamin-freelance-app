import 'package:intl/intl.dart';

class OfferingDetail {
  String? idOrder;
  String? jobTitle;
  String? clientName;
  String? keluhan;
  String? noWaClient;
  int? idStatus;
  String? status;
  String? biaya;
  String? komentar;
  String? rating;
  double? longitude;
  double? latitude;

  OfferingDetail(
    this.idOrder,
    this.jobTitle,
    this.clientName,
    this.keluhan,
    this.noWaClient,
    this.idStatus,
    this.status,
    this.biaya,
    this.komentar,
    this.rating,
    this.longitude,
    this.latitude,
  ) {
    this.jobTitle = toBeginningOfSentenceCase(this.jobTitle);
  }
}
