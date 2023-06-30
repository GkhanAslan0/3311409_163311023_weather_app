import 'package:flutter/material.dart';
import 'package:flutter_weather_app/home_page.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/search.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: TextField(
                    onChanged: (value) {
                      selectedCity = value;
                      print(value);
                    },
                    decoration: InputDecoration(
                        hintText: "Şehir İsmini Yazın",
                        hintStyle: TextStyle(color: Colors.white),
                        border:
                            OutlineInputBorder(borderSide: BorderSide.none)),
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var response = await http.get(Uri.parse(
                        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=8ec1f9e185d7391b462cc84d66d59696'));
                    if (response.statusCode == 200) {
                      Navigator.pop(context, selectedCity);
                    } else {
                      _showMyDialog();
                    }
                  },
                  child: Text(
                    'Şehri Seç',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: Text(
                    "Konuma dön",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    shadowColor: Colors.grey,
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şehir Bulunamadı'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lütfen Tekrar Kontrol Edin'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
