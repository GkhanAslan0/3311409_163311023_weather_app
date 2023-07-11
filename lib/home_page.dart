import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_weather_app/Widgets/daily_weather_card.dart';
import 'package:flutter_weather_app/search_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_weather_app/todo_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = '';
  double? temperature;
  final String key = '8ec1f9e185d7391b462cc84d66d59696';
  var locationData;
  String code = 'home';
  Position? devicePosition;
  String? icon;

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed['main']['temp'].toDouble();
      location = locationDataParsed['name'];
      code = locationDataParsed['weather'].first['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed['main']['temp'].toDouble();
        location = locationDataParsed['name'];
        code = locationDataParsed['weather'].first['main'];
        icon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    devicePosition = await _determinePosition();
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecast = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecast.body);

    temperatures.clear();
    icons.clear();
    dates.clear();
    setState(() {
      for (int i = 7; i < 40; i += 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecast = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecast.body);

    temperatures.clear();
    icons.clear();
    dates.clear();
    setState(() {
      for (int i = 7; i < 40; i += 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon();
    await getDailyForecastByLatLon();
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/$code.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: (temperature == null ||
              devicePosition == null ||
              icons.isEmpty ||
              dates.isEmpty ||
              temperatures.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 125,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(100, 255, 255, 255)
                                  .withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 50,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Image.network(
                          'https://openweathermap.org/img/wn/$icon@2x.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      "$temperature°C",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(5, 5),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(5, 5),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final selectedCity = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(),
                              ),
                            );
                            location = selectedCity;
                            getLocationDataFromAPI();
                            getDailyForecastByLocation();
                          },
                          icon: Icon(
                            Icons.search_outlined,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    buildWeatherCards(context),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TodoApp(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade800,
                              Colors.blue.shade500
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Not Sayfasına Git',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];
    int itemCount = temperatures.length;
    for (int i = 0; i < itemCount; i++) {
      cards.add(
        DailyWeatherCard(
          icon: icons[i],
          temperature: temperatures[i],
          date: dates[i],
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return cards[index];
        },
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }
}
