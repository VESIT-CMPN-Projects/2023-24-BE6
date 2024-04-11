// import 'dart:convert';
// import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  late BitmapDescriptor customMarkerIcon;

  Set<Marker> markers = {};
  Set<Circle> circles = {};
  // bool isLoading = true;

  Stream<QuerySnapshot>? stream;
  Map<String, LatLng> addressCoordinates = {};

  Future<BitmapDescriptor> createCustomMarkerIcon(String imagePath,
      {int width = 100, int height = 100}) async {
    // Your existing implementation
    final ByteData byteData = await rootBundle.load(imagePath);

    final Uint8List uint8List = byteData.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(uint8List,
        targetHeight: height, targetWidth: width);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedByteData =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedUint8List = resizedByteData!.buffer.asUint8List();
    return BitmapDescriptor.fromBytes(resizedUint8List);
  }
}
