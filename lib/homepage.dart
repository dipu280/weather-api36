import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latiitude = position!.latitude;
      longatute = position!.longitude;
    });
    fetchWeatherData();
  }

  var latiitude;
  var longatute;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forcastMap;
  fetchWeatherData() async {
    String weatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latiitude&lon=$longatute&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=10dca9a4d247c6d58647dcffd3f26f39';
    String forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?lat=37.4219983&lon=-122.084&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=10dca9a4d247c6d58647dcffd3f26f39';

    var weatherResponce = await http.get(Uri.parse(weatherUrl));
    var forecasteResponce = await http.get(Uri.parse(forecastUrl));
    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
    forcastMap = Map<String, dynamic>.from(jsonDecode(forecasteResponce.body));
    setState(() {});
    print("*********${latiitude},$longatute");
  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "${Jiffy(DateTime.now()).format("MMM do yy, h:mm a")}",
                style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "${weatherMap!['name']}",
                style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "${weatherMap!['main']["temp"]}°",
                style: myStyle(42, Color.fromARGB(255, 44, 44, 44)),
              ),
            ),
            SizedBox(
              height: 80,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${weatherMap!['main']["feels_like"]}°",
                      style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Feels like: ${weatherMap!['weather'][0]["description"]}°",
                      style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "Humidity ${weatherMap!['main']['humidity']},Pressure ${weatherMap!['main']['pressure']}",
              style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
            ),
            Text(
              "Sunrise: ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format('h:mm a')}",
              style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forcastMap!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 8),
                      color: Color.fromARGB(255, 106, 131, 143),
                      width: 200,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${Jiffy(forcastMap!['list'][index]['dt_txt']).format('EEE h:mm')}',
                            style: myStyle(20, Color.fromARGB(255, 44, 44, 44)),
                          ),
                          Image.network(
                              "http://openweathermap.org/img/wn/${forcastMap!['list'][index]['weather'][0]['icon']}@2x.png"),
                          Text(
                            "${forcastMap!['list'][index]['main']['temp_min']}/${forcastMap!['list'][index]['main']['temp_max']}",
                            style: myStyle(22, Color.fromARGB(255, 44, 44, 44)),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${forcastMap!['list'][index]['weather'][0]['description']}",
                            style: myStyle(25, Color.fromARGB(255, 44, 44, 44)),
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    ));
  }
}

myStyle(double size, Color color, [FontWeight? fontWeight]) {
  return TextStyle(fontSize: size, color: color, fontWeight: fontWeight);
}
