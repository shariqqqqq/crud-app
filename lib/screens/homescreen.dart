// home_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'productlist.dart';
import '../product/product.dart';
class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> banners = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String apiUrl =
        'https://virashtechnologies.com/test-virash/banners.php?banner_type=slider';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        if (responseData is List) {
          setState(() {
            banners = responseData
                .whereType<Map<String, dynamic>>() // Filter only maps
                .map<Map<String, String>>((dynamic map) {
              return map.cast<String, String>();
            }).toList();
          });
        } else {
          print('Invalid response format');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.tealAccent,
        title: Text("Home page"),
      ),
      body: Column(
        children: [
          // Carousel Slider
          CarouselSlider(
            items: banners
                .map(
                  (banner) => Image.network(
                'https://virashtechnologies.com/test-virash/${banner['banner_image']}',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
                .toList(),
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              aspectRatio: 16 / 9,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              enlargeCenterPage: true,
            ),
          ),
          SizedBox(height: 200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(),
                    ),
                  );
                  print('Category button pressed');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Category', style: TextStyle(fontSize: 18)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductListPage(),
                    ),
                  );
                  print('Product button pressed');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text('Product', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
