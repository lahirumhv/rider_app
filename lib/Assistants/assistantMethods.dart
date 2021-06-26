import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/Models/allUsers.dart';
import 'package:rider_app/Models/directDetails.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, BuildContext context) async {
    String placeAddress = "";
    String st1, st2, st3;

    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "Failed.") {
      //══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
      // The following assertion was thrown during layout: (MainScreen Text in Row widget)
      // A RenderFlex overflowed by 55 pixels on the right.

      // placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
      st3 = response["results"][0]["address_components"][2]["long_name"];

      placeAddress = st1 + ", " + st2 + ", " + st3 + ", ";
      Address userPickUpAddress = Address(
          latitude: position.latitude,
          longitude: position.longitude,
          placeName: placeAddress);

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionsUrl);

    if (res == "Failed.") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    if (res["status"] == "OK") {
      directionDetails.distanceText =
          res["routes"][0]["legs"][0]["distance"]["text"];
      directionDetails.distanceValue =
          res["routes"][0]["legs"][0]["distance"]["value"];
      directionDetails.durationText =
          res["routes"][0]["legs"][0]["duration"]["text"];
      directionDetails.durationValue =
          res["routes"][0]["legs"][0]["duration"]["value"];

      directionDetails.encodedPoints =
          res["routes"][0]["overview_polyline"]["points"];
    }
    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails) {
    // in terms of USD per km and per minute
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;

    double totalFareAmount = timeTraveledFare + distanceTraveledFare;
    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser!.uid;

    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        userCurrentInfo = Users.fromSnap(dataSnapshot);
      }
    });
  }
}
