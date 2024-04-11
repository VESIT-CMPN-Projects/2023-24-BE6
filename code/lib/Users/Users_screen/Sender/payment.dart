// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:deliveryx/Users/Users_screen/Sender/SenderPayment.dart';
// import 'package:deliveryx/provider/senderProvider.dart';

// class PriceCalculator extends StatefulWidget {
//   const PriceCalculator({super.key});

//   @override
//   _PriceCalculatorState createState() => _PriceCalculatorState();
// }

// class _PriceCalculatorState extends State<PriceCalculator> {
//   // Remove distanceController if not needed
//   // TextEditingController distanceController = TextEditingController();

//   // Initialize weightClass and sizeClass
//   String weightClass = "";
//   String sizeClass = "";
//   double totalPrice = 0.0;
//   double distance = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     {
//       calculateDistance();
//     }
//   }

// //1
//   Future<void> calculateDistance() async {
//     Sender sender = Provider.of<SenderProvider>(context, listen: false).sender;
//     String location1 = sender.location1;
//     String location2 = sender.location2;

//     List<Location> firstLocation = await locationFromAddress(location1);
//     List<Location> secondLocation = await locationFromAddress(location2);

//     double lat1 = firstLocation[0].latitude;
//     double long1 = firstLocation[0].longitude;
//     double lat2 = secondLocation[0].latitude;
//     double long2 = secondLocation[0].longitude;

//     double calculatedDistance = Geolocator.distanceBetween(
//       lat1,
//       long1,
//       lat2,
//       long2,
//     );

//     setState(() {
//       distance = calculatedDistance / 1000;
//     });
//     calculateTotalPrice(context);
//   }

// //2
//   double calculateDistanceFactor(int distance, {double factor = 0.80}) {
//     if (distance <= 0) {
//       return factor;
//     } else {
//       return calculateDistanceFactor(distance - 1, factor: factor + 0.20);
//     }
//   }

//   calculateTotalPrice(context) {
//     try {
//       Sender sender =
//           Provider.of<SenderProvider>(context, listen: false).sender;
//       print('------->');
//       print(sender.size);
//       print(sender.weight);

//       // Initialize weightClass and sizeClass
//       // You can modify this based on your requirements
//       // setState(() {
//       //   weightClass = sender.weight;
//       //   sizeClass = sender.size;
//       // });

//       double w;
//       if (sender.weight == "Upto 1 kg") {
//         w = 0;
//       } else if (sender.weight == "Upto 3 kg") {
//         w = 0;
//       } else if (sender.weight == "Upto 5 kg") {
//         w = 75.0;
//       } else {
//         setState(() {
//           totalPrice = 0.0;
//         });
//         return;
//       }

//       double s;
//       if (sender.size == "Small") {
//         s = 0;
//       } else if (sender.size == "Medium") {
//         s = 0;
//       } else if (sender.size == "Large") {
//         s = 25.0;
//       } else if (sender.size == "Xtra Large") {
//         s = 50.0;
//       } else {
//         setState(() {
//           totalPrice = 0.0;
//         });

//         return;
//       }

//       double distanceFactor = calculateDistanceFactor(distance.toInt());
//       double basePrice = 40;

//       double total = basePrice * (distanceFactor) + s + w;

//       setState(() {
//         totalPrice = total;
//       });
//       print("------------->$totalPrice");
//       // Push the total price to SenderPayment screen
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => SenderPayment(
//       //       totalCost: totalPrice,
//       //     ),
//       //   ),
//       // );
//     } catch (e) {
//       setState(() {
//         print("------------>catch ${e.toString()}");
//         totalPrice = 0.0;
//       });
//     }
//   }

//   //------>

//   @override
//   Widget build(BuildContext context) {
//     Sender sender = Provider.of<SenderProvider>(context).sender;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("DelXPrice"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Distance (km): ${distance.toStringAsFixed(2)}"),
//             const SizedBox(height: 16.0),
//             Text(
//               "Total Price: ${totalPrice.toStringAsFixed(2)}",
//               style: const TextStyle(fontSize: 16.0),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () async {
//                 // Calculate and push total price when the button is pressed

//                 // calculateTotalPrice(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => SenderPayment(totalCost: totalPrice),
//                   ),
//                 );
//               },
//               child: const Text('Calculate Total Price'),
//             ),
//             const SizedBox(height: 16.0),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text('Sender Location: ${sender.location1}'),
//                 Text('Receiver Location: ${sender.location2}'),
//                 Text('Weight: ${sender.weight}'),
//                 Text('Size: ${sender.size}'),
//                 Text('Ins. Amt: ${sender.insuranceAmt}'),
//                 Text(
//                   '${distance.toStringAsFixed(2)} meters',
//                   style: const TextStyle(fontSize: 24),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
