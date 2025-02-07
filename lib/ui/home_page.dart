import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:weather_kita/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Constants constants = Constants();
  final TextEditingController cityController = TextEditingController();
  static String apiKey = '9cee1f7a49b7412abc401732250702';

  String location = 'Jakarta'; // default location
  String weatherIcon = 'assets/sunny.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyForecast = [];
  List dailyForecast = [];

  String currentWeatherStatus = '';

  bool isLoading = true; // Untuk efek shimmer

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
        temperature = data['current']['temp_c'].toInt();
        windSpeed = data['current']['wind_kph'].toInt();
        humidity = data['current']['humidity'].toInt();
        cloud = data['current']['cloud'].toInt();

        // weather status
        currentWeatherStatus = data['current']['condition']['text'];
        weatherIcon = getWeatherIcon(currentWeatherStatus);

        // date
        var parseDate = DateTime.parse(data['location']['localtime']);
        var newDate = DateFormat('EEEE, d MMMM y').format(parseDate);
        currentDate = newDate;

        // forecast data
        hourlyForecast = data['forecast']['forecastday'][0]['hour'];
        dailyForecast = data['forecast']['forecastday'];

        isLoading = false; // Matikan shimmer setelah data selesai dimuat
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false; // Matikan shimmer jika terjadi error
      });
    }
  }

  String getWeatherIcon(String condition) {
    String iconPath =
        'assets/${condition.replaceAll(' ', '').toLowerCase()}.png';
    // Jika gambar tidak ditemukan, gunakan gambar default
    if (AssetImage(iconPath).evict() == false) {
      return 'assets/default.png'; // Gambar default
    }
    return iconPath;
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
      backgroundColor: constants.primaryColor.withOpacity(0.1),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
              top: 40, bottom: 20), // Padding di bagian atas
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with location and search
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu,
                        color: constants.tertiaryColor.withOpacity(0.8)),
                    onPressed: () {},
                  ),
                  Row(
                    children: [
                      Lottie.asset(
                        'assets/pin.json',
                        width: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: constants.tertiaryColor.withOpacity(0.8),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cityController.clear();
                          showMaterialModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              height: size.height * 0.7, // Modal lebih tinggi
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: Divider(
                                      thickness: 3.5,
                                      color: constants.tertiaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    onChanged: (searchText) {
                                      fetchWeather(searchText);
                                    },
                                    controller: cityController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: constants.tertiaryColor,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () => cityController.clear(),
                                        child: Icon(
                                          Icons.close,
                                          color: constants.tertiaryColor,
                                        ),
                                      ),
                                      hintText: 'Search City, e.g. Jakarta',
                                      hintStyle: TextStyle(
                                        color: constants.greyColor,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: constants.tertiaryColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: constants.tertiaryColor.withOpacity(0.8),
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
              const SizedBox(height: 20),

              // Weather Icon and Temperature
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 150,
                        height: 150,
                        color: Colors.white,
                      ),
                    )
                  : Image.asset(
                      weatherIcon,
                      width: 150,
                      height: 150,
                    ),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 50,
                        color: Colors.white,
                      ),
                    )
                  : AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          '$temperature°C',
                          textStyle: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            constants.primaryColor,
                            constants.secondaryColor,
                            constants.tertiaryColor,
                          ],
                        ),
                      ],
                      isRepeatingAnimation: true,
                    ),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 100,
                        height: 20,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      currentWeatherStatus,
                      style: TextStyle(
                        fontSize: 20,
                        color: constants.tertiaryColor.withOpacity(0.8),
                      ),
                    ),
              const SizedBox(height: 10),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 150,
                        height: 16,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      currentDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: constants.greyColor,
                      ),
                    ),
              const SizedBox(height: 20),

              // Additional Weather Details
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff6b9dfc), Color(0xffa1c6fd)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: constants.primaryColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWeatherDetail(
                        'Wind', '$windSpeed km/h', 'assets/windspeed.png'),
                    _buildWeatherDetail(
                        'Humidity', '$humidity%', 'assets/humidity.png'),
                    _buildWeatherDetail('Cloud', '$cloud%', 'assets/cloud.png'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hourly Forecast
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: constants.tertiaryColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: Colors.white,
                      ),
                    )
                  : SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyForecast.length,
                        itemBuilder: (context, index) {
                          var hour = hourlyForecast[index];
                          var time = DateFormat('HH:mm')
                              .format(DateTime.parse(hour['time']));
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: constants.secondaryColor
                                        .withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Image.asset(
                                  getWeatherIcon(hour['condition']['text']),
                                  width: 40,
                                  height: 40,
                                ),
                                Text(
                                  '${hour['temp_c'].toInt()}°C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        constants.primaryColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),

              // Daily Forecast
              Text(
                'Daily Forecast',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: constants.tertiaryColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: dailyForecast.map((day) {
                  var date =
                      DateFormat('EEEE').format(DateTime.parse(day['date']));
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff6b9dfc), Color(0xffa1c6fd)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: constants.primaryColor.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        getWeatherIcon(day['day']['condition']['text']),
                        width: 40,
                        height: 40,
                      ),
                      title: Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        '${day['day']['avgtemp_c'].toInt()}°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, String iconPath) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
