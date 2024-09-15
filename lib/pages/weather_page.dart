import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/utils/weather_services.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherServices('253b0ad40a5c07be518640b342f60f81');
  Weather? _weather;
  final TextEditingController _typeAheadController = TextEditingController();

  // Function to fetch weather based on city name
  _fetchWeather([String? cityName]) async {
    try {
      String location = cityName ?? await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(location);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather(); // Fetch weather for current location initially
  }

  // Function to fetch city suggestions using OpenWeather Geocoding API
  Future<List<String>> _getCitySuggestions(String query) async {
    final apiKey = '253b0ad40a5c07be518640b342f60f81';
    final url = Uri.parse('http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> cities = json.decode(response.body);
      return cities.map((city) => city['name'] as String).toList();
    } else {
      throw Exception('Failed to load city suggestions');
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'cloud':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 12),
              // TypeAheadField for city name input with suggestions
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    decoration: InputDecoration(
                      hintText: "Enter city name:",
                      filled: true,
                      fillColor: Colors.grey[400],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _fetchWeather(value); // Fetch weather based on the submitted value
                        _typeAheadController.clear();
                      }
                    },
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) {
                      return [];  // Return an empty list when the input is empty
                    }
                    return await _getCitySuggestions(pattern);
                  },
                  itemBuilder: (context, String suggestion) {
                    return ListTile(
                      tileColor: Colors.grey[400],
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (String suggestion) {
                    _typeAheadController.text = suggestion;
                    _fetchWeather(suggestion);
                    _typeAheadController.clear();
                  },
                  noItemsFoundBuilder: (context) => ListTile(
                    tileColor: Colors.grey[400],
                    title:const Text(
                      'No cities found',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 20),
        
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weather?.cityName ?? "Loading City...",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),

                      Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

                      Text(
                        '${_weather?.temperature.round()}°C',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        _weather?.mainCondition ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
