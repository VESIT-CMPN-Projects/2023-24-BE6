import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateOrderWithTravelerList(
      String? senderId, String? orderId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Get current timestamp

      // Initialize or reference the 'users' collection
      CollectionReference usersCollection = _firestore.collection('users');

      // Reference to the specific order document
      DocumentReference orderReference =
          usersCollection.doc(senderId).collection('orders').doc(orderId);

      print('Updating order: $orderId for sender: $senderId');

      // Get existing data or create a new one
      DocumentSnapshot orderSnapshot = await orderReference.get();
      await orderSnapshot.get({
        'travellerList': [],
      });
      print('Existing Order Snapshot: ${orderSnapshot.data()}');

      List<String> travelerList =
          List<String>.from(orderSnapshot.get('travellerList') ?? []);

      // Add current user's ID to the traveler list
      travelerList.add(user.uid);

      // Update the order document with the traveler list and status
      await orderReference.update({
        'travelerList': travelerList,
        'Status': 'Processing',
      });

      // Print the updated traveler list for debugging
      print('Updated Traveler List: $travelerList');

      // Fetch the updated order snapshot for further debugging
      DocumentSnapshot updatedOrderSnapshot = await orderReference.get();
      print('Updated Order Snapshot: ${updatedOrderSnapshot.data()}');
    }
  }
}
