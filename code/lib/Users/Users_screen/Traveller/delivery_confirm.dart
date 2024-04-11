import 'package:deliveryx/Users/Users_screen/Traveller/current_user_location.dart';
import 'package:flutter/material.dart';

class DeliveryConfirmation extends StatefulWidget {
  final int prevPage;
  final String? orderId;
  final String? senderId;

  const DeliveryConfirmation({
    Key? key,
    required this.prevPage,
    required this.orderId,
    required this.senderId,
  }) : super(key: key);

  @override
  _DeliveryConfirmationState createState() => _DeliveryConfirmationState();
}

class _DeliveryConfirmationState extends State<DeliveryConfirmation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Prev Page: ${widget.prevPage}'),
          Text('Order ID: ${widget.orderId}'),
          Text('Sender ID: ${widget.senderId}'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GetUserCurrentLocationScreen(
                  prevPage: 1, // Replace with the appropriate value
                  orderId: widget.orderId,
                  senderId: widget.senderId,
                ),
              ),
            );
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
