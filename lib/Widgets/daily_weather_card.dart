import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard(
      {super.key,
      required this.icon,
      required this.temperature,
      required this.date});

  final String icon;
  final double temperature;
  final String date;
  @override
  Widget build(BuildContext context) {
    final parsedTime = DateTime.parse(date);
    List<String> weekdays = [
      "Pazartesi",
      "Sali",
      "Çarşamba",
      "Perşembe",
      "Cuma",
      "Cumartesi",
      "Pazar",
    ];

    return Card(
      color: Color.fromARGB(100, 255, 255, 255),
      child: SizedBox(
          height: 130,
          width: 80,
          child: Column(
            children: [
              Image.network('https://openweathermap.org/img/wn/$icon@2x.png'),
              Text("$temperature°C",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(weekdays[parsedTime.weekday - 1]),
            ],
          )),
    );
  }
}
