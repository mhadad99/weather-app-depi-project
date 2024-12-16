import 'package:dartz/dartz.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/core/services/errors/location_failure.dart';

class MyLocation {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services is turned on or off.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw CurrentLocationException('Please turn on location service!');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw CurrentLocationException('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw CurrentLocationException(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Either<LocationFailure, String?>> getCurrentCity() async {
    try {
      Position position = await _determinePosition();

      List<Placemark> locationDetails =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String? city = locationDetails[0].subAdministrativeArea;
      return right(city);
    } on CurrentLocationException catch (e) {
      return left(LocationFailure(e.cause));
    } catch (e) {
      return left(LocationFailure("Error!!"));
    }
  }
}
