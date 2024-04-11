//user : ansaritaufique379
//password : lrwBtLHltqsPdCtu

import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static const mongo_url =
      'mongodb+srv://ansaritaufique379:lrwBtLHltqsPdCtu@deliveryx.v5bbcnw.mongodb.net/test?retryWrites=true&w=majority&appName=DeliveryX';
  // static const collection_name = "orders";
  // static connect() async {
  //   var db = await Db.create(mongo_url);
  //   await db.open();
  //   var collection = db.collection(collection_name);
  // }
  static const collection_name = "orders";
  static Db? _db;
  static late DbCollection _collection;

  static Future<void> connect() async {
    _db = await Db.create(mongo_url);
    await _db!.open();
    _collection = _db!.collection(collection_name);
  }

  static Future<void> insert(double lat, double long, String orderId) async {
    if (_db == null) {
      await connect();
    }

    await _collection.insert({
      'latitude': lat,
      'longitude': long,
      'orderId': orderId,
    });
  }

  static Future<void> updateOrCreate(
      double lat, double long, String orderId) async {
    print("rrrrr $lat $long");
    if (_db == null) {
      await connect();
    }

    // Check if a document with the given order ID exists
    var existingDocument =
        await _collection.findOne(where.eq('orderId', orderId));
    if (existingDocument != null) {
      // Update the existing document
      await _collection.update(
        where.eq('orderId', orderId),
        modify.set('latitude', lat).set('longitude', long),
      );
    } else {
      // Create a new document
      await _collection.insert({
        'latitude': lat,
        'longitude': long,
        'orderId': orderId,
      });
    }
  }

  static Future<List> readLocationByOrderId(String orderId) async {
    var location = await _collection.findOne(where.eq('orderId', orderId));
    List<double> locationArray = [location!['latitude'], location['longitude']];
    // fields: ['latitude', 'longitude']);
    print(location);
    return locationArray;
  }
}
