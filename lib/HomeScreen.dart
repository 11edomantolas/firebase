import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:flutter/xmaterial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyLocation extends StatefulWidget {
  const MyLocation({key});

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  String location = 'Find your Coordinate point now...';
  String Address = 'Find your Address now....';

  double defaultMargin = 25;
  double defaultPadding = 16.0;

  Color blueColor = Colors.blueAccent;
  Color whiteColor = Colors.white;
  Color blackColor = Colors.black;
  Color greyColor = Colors.grey.shade300;

  TextStyle appTextStyle = GoogleFonts.inter(
      fontSize: 36, color: Colors.black, fontWeight: FontWeight.w700);
  TextStyle whiteTextStyle = GoogleFonts.nunito(
      fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500);
  TextStyle blackTextStyle = GoogleFonts.nunito(
      fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500);
  TextStyle boldTextStyle = GoogleFonts.poppins(
      fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold);

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  final cari = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      print(auth.currentUser!.email);
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blueColor,
        centerTitle: true,
        title: Text(
          'lokasi',
          style: whiteTextStyle.copyWith(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Coordinates Points',
              style: whiteTextStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              location,
              style: whiteTextStyle.copyWith(
                  fontSize: 16, color: Colors.grey.shade800),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Address',
              style: whiteTextStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                '${Address}',
                style: whiteTextStyle.copyWith(
                    fontSize: 16, color: Colors.grey.shade800),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                Position position = await _getGeoLocationPosition();
                location =
                    'Lat: ${position.latitude} , Long: ${position.longitude}';
                GetAddressFromLatLong(position);
              },
              child: Text(
                'Get Location',
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  shadowColor: blueColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Find your destination',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextFormField(
                autofocus: false,
                controller: cari,
                decoration: InputDecoration(
                    hintText: "Search...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                final intent = AndroidIntent(
                    action: 'action_view',
                    data: Uri.encodeFull(
                        'google.navigation:q=${cari.text.trim()}'),
                    package: 'com.google.android.apps.maps');
                await intent.launch();
              },
              child: Text(
                'Find Location',
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  shadowColor: blueColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ],
        ),
      ),
    );
  }
}
