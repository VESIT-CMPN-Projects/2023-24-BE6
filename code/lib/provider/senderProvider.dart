import 'package:flutter/cupertino.dart';

class Sender {
  String location1;
  String location2;
  String weight;
  String size;
  String senderName;
  String senderNumber;
  int insuranceAmt;
//  String orderId;

  Sender(
      {required this.location1,
      required this.location2,
      required this.weight,
      required this.size,
      required this.insuranceAmt,
      required this.senderName,
      //  required this.orderId,
      required this.senderNumber});
}

class SenderProvider extends ChangeNotifier {
  Sender _sender = Sender(
      location1: '',
      location2: '',
      weight: '',
      size: '',
      insuranceAmt: 0,
      senderName: '',
      senderNumber: ''
      // orderId: ''
      );

  Sender get sender => _sender;

  void updateSender(Sender newSender) {
    _sender = newSender;
    notifyListeners();
  }
}
