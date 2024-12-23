import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_buddy/screens/search_screen.dart';

import '../services/networking.dart';


class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: const Center(
          child: const SpinKitDoubleBounce(
              size: 70,
              color: Colors.white
          )
      ),
    );
  }

  void getWeatherData() async {
    Networking network = new Networking();
    String data = await network.getData();
    print(data);

    Navigator.push(context, MaterialPageRoute(builder:(context){
      return SearchScreen(data);
    }));
  }
}