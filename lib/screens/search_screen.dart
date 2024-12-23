import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:weather_buddy/screens/sky_screen.dart';

import 'dart:convert';

import '../others/constants.dart';
import '../services/location.dart';
import '../services/networking.dart';
import '../services/weather.dart';

class SearchScreen extends StatefulWidget {
  String newcity = '';
  SearchScreen(this.data, {super.key});
  String data = '';
  @override
  State<SearchScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<SearchScreen> {
  double temp = 0;
  String city = '', info = '', weathericon = '', weathermessage = '';
  int id = 0;

  double currentLat = 0.0;
  double currentLon = 0.0;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    info = widget.data;
    updateUI();
    getCurrentLocation();
  }

  void updateUI() {
    try {
      temp = jsonDecode(info)['main']['temp'];
      city = jsonDecode(info)['name'];
      id = jsonDecode(info)['weather'][0]['id'];

      WeatherModel weatherModel = WeatherModel();
      weathericon = weatherModel.getWeatherIcon(id);
      weathermessage = weatherModel.getMessage(temp.toInt());
      isError = false;
    } catch (e) {
      print("Error updating UI: $e");
      isError = true;
      city = "Error";
      weathericon = "❌";
      weathermessage = "No city with that name";
    }
  }

  void getCurrentLocation() async {
    Location location = Location();
    await location.getLocation();
    currentLat = location.lat;
    currentLon = location.lon;

    Networking network = Networking();
    String weatherData = await network.getData(cityName: '');

    setState(() {
      info = weatherData;
      updateUI();
    });
  }

  void getWeatherForCity(String cityName) async {
    Networking network = Networking();
    String weatherData = await network.getData(cityName: cityName);

    if (weatherData == "error") {
      setState(() {
        isError = true;
        city = "Error";
        weathericon = "❌";
        weathermessage = "No city with that name";
      });
    } else {
      setState(() {
        info = weatherData;
        updateUI();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        size: 35.0,
                        color: Colors.white,
                      ),
                      onPressed: getCurrentLocation,
                    ),
                    Text(
                      'Weather Buddy',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 35.0,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        String newcity = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return SkyScreen();
                            }));
                        getWeatherForCity(newcity);
                        if (newcity.isEmpty) {
                          setState(() {
                            isError = true;
                            city = "Error";
                            weathericon = "❌";
                            weathermessage = "City name not be empty!";
                          });
                        } else {
                          getWeatherForCity(newcity);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        isError
                            ? const Text(
                          'Error',
                          style: kTempTextStyle,
                        )
                            : Text(
                          '${temp.toStringAsFixed(0)}°',
                          style: kTempTextStyle,
                        ),
                        Text(
                          weathericon,
                          style: kConditionTextStyle,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                      child: Text(
                        isError ? weathermessage : "$weathermessage in $city",
                        textAlign: TextAlign.center,
                        style: kMessageTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
