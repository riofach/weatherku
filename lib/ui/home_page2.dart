import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather_kita/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Constants constants = Constants();
  final TextEditingController cityController = TextEditingController();
  static String apiKey = '9cee1f7a49b7412abc401732250702';

  String location = 'Jakarta'; //default location
  String weatherIcon = 'assets/sunny.json';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyForecast = [];
  List dailyForecast = [];

  String currentWeatherStatus = '';

  // API CALL
  String searchWeatherURL =
      'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&days=7&q=';

  Future<void> fetchWeather(String searchText) async {
    try {
      var response = await http.get(Uri.parse(searchWeatherURL + searchText));
      var data = jsonDecode(response.body);
      print(data);
      setState(() {
        location = data['location']['name'];
        temperature = data['current']['temp_c'].toint();
        windSpeed = data['current']['wind_kph'].toint();
        humidity = data['current']['humidity'].toint();
        cloud = data['current']['cloud'].toint();

        // weather status
        currentWeatherStatus = data['current']['condition']['text'];
        weatherIcon =
            '${currentWeatherStatus.replaceAll(' ', '').toLowerCase()}.json';
        var iconLottie = Lottie.asset(
          weatherIcon,
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        );

        // date
        var parseDate = data['location']['localtime'];
        var newDate = DateFormat('MMMMEEEEd').format(parseDate);
        currentDate = newDate;

        // forecast data
        hourlyForecast = data['forecast']['forecastday'][0]['hour'];
        dailyForecast = data['forecast']['forecastday'];
      });
    } catch (e) {
      // print(e);
    }
  }

  // Function to get the short location name
  static String getShortLocationName(String locationName) {
    // Split the location name by spaces
    List<String> wordList = locationName.split(' ');

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + ' ' + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return '';
    }
  }

  @override
  void initState() {
    fetchWeather(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 70, left: 10, right: 10),
        color: constants.primaryColor.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * .7,
              decoration: BoxDecoration(
                gradient: constants.linearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: constants.primaryColor.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/menu.png',
                      width: 40,
                      height: 40,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/pin.json',
                          width: 20,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            cityController.clear();
                            showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) => SingleChildScrollView(
                                      controller:
                                          ModalScrollController.of(context),
                                      child: Container(
                                        height: size.height * .2,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: 70,
                                              child: Divider(
                                                thickness: 3.5,
                                                color: constants.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TextField(
                                              onChanged: (searchText) {
                                                fetchWeather(searchText);
                                              },
                                              controller: cityController,
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color:
                                                        constants.primaryColor,
                                                  ),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () =>
                                                        cityController.clear(),
                                                    child: Icon(
                                                      Icons.close,
                                                      color: constants
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  hintText:
                                                      'Search City, e.g. Jakarta',
                                                  hintStyle: TextStyle(
                                                    color: constants.greyColor,
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: constants
                                                            .primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                          },
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/profile.png',
                        fit: BoxFit.cover,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 160,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
