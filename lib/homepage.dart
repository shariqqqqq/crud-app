import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/homescreen.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _scaleAnimation;

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _slideUpAnimation = Tween<Offset>(begin: Offset(0, -10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final String apiUrl = 'https://virashtechnologies.com/test-virash/login.php';

    final Map<String, dynamic> data = {
      'mobile_number': mobileNumberController.text,
      'password': passwordController.text,
      'type': 'Login',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode([data]),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            List<dynamic> responseData = json.decode(response.body);

            if (responseData.isNotEmpty && responseData[0]['success'] == 1) {
              String token = responseData[0]['token'];
              await _saveTokenLocally(token);
              await _saveMobileNumberLocally(mobileNumberController.text);
              print(token);

              // Navigate to the home screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
              );
            } else {
              final errorMessage = responseData[0]['message'] ?? 'Unknown error';
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Login Failed'),
                    content: Text(errorMessage),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          } catch (e) {
            // Handle JSON decoding error
            print('JSON decoding error: $e');
          }
        } else {
          // Handle empty response body
          print('Empty response body');
        }
      } else {
        // Handle HTTP error
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle request/send error
      print('Request/send error: $e');
    }
  }

  Future<void> _saveTokenLocally(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _saveMobileNumberLocally(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileNumber', mobileNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login page"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(05.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(),
                  _inputField(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _login(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _header() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideUpAnimation.value.dy),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: const Column(
              children: [
                Text(
                  "Welcome To The Crud App",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _inputField() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideUpAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType:TextInputType.number,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                fillColor: Colors.purple.withOpacity(0.1),
                filled: true,
                prefixIcon: const Icon(Icons.password_sharp),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }
}
