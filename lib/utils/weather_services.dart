import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherServices {
  static const  BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherServices(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    try {
      final encodedCityName = Uri.encodeComponent(cityName); // Encodes the city name
      final response = await http.get(Uri.parse('$BASE_URL?q=$encodedCityName&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String? city = placeMarks[0].locality;

      return city ?? 'Unknown City';
    } catch (e) {
      throw Exception('Error retrieving current city: $e');
    }
  }
}
