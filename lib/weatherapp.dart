import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/HourlyForecastItem.dart';
import 'package:weather_app/secrets.dart'; // Ensure this file exists and contains your API key.
import 'Additional_Info.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController cityNameController = TextEditingController();
  double currenttemp = 0;
  String currentsky = '';
  double currenthumidity = 0;
  double currentPressure = 0;
  double windspeed = 0.0;
  String cityname = 'Pune';

  Future<Map<String, dynamic>> getcurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$openWhetherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getcurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('An Unexpected Error Occurred'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No Data Available'));
          }

          final data = snapshot.data!;
          final currentWeather = data['list'][0];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: cityNameController,
                    decoration: const InputDecoration(
                      hintText: '   Enter City Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(25),
                          right: Radius.circular(25),
                        ),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        cityname = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 10,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Text(
                                  '${(currentWeather['main']['temp'] - 273.15).toStringAsFixed(2)} °C', // Convert Kelvin to Celsius
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Icon(
                                  currentWeather['weather'][0]['main'] ==
                                              'Rain' ||
                                          currentWeather['weather'][0]
                                                  ['main'] ==
                                              'Clouds'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 68,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentWeather['weather'][0]['main'],
                                  style: const TextStyle(fontSize: 25),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weather Forecast',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < data['list'].length - 1; i++)
                          if (DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                              data['list'][i + 1]['dt_txt']
                                  .toString()
                                  .split(" ")[0])
                            cardwhethercast(
                              time: DateFormat('h:mm a').format(DateTime.parse(
                                  data['list'][i + 1]['dt_txt'])),
                              temperature:
                                  (data['list'][i + 1]['main']['temp'] - 273.15)
                                      .toStringAsFixed(
                                          2), // Convert Kelvin to Celsius
                              icon: data['list'][i + 1]['weather'][0]['main'] ==
                                          'Rain' ||
                                      data['list'][i + 1]['weather'][0]
                                              ['main'] ==
                                          'Drizzle'
                                  ? Icons.water_drop
                                  : data['list'][i + 1]['weather'][0]['main'] ==
                                          'Clouds'
                                      ? Icons.cloud
                                      : data['list'][i + 1]['weather'][0]
                                                  ['main'] ==
                                              'Clear'
                                          ? Icons.sunny
                                          : Icons.help,
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Additioninfo(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentWeather['main']['humidity'].toDouble(),
                      ),
                      Additioninfo(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: currentWeather['wind']['speed'].toDouble(),
                      ),
                      Additioninfo(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: currentWeather['main']['pressure'].toDouble(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
