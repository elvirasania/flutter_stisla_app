// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'dart:convert';
import 'package:flutter_stisla_app/screens/auth/register.dart';
import 'package:flutter_stisla_app/screens/home/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stisla_app/network/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController =
      TextEditingController(text: 'superadmin@gmail.com');
  TextEditingController passwordController =
      TextEditingController(text: 'password');

  void login() async {
    var headers = {'Content-Type': 'application/json'};
    if (emailController.text == '' || passwordController.text == '') {
      showError('Warning', 'Email dan password harus diisi');
    } else {
      try {
        var url = Uri.parse(ApiUrls().baseUrl + ApiUrls().login);
        Map body = {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        };
        final response =
            await http.post(url, body: jsonEncode(body), headers: headers);

        print(response.statusCode);
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['token'] != null) {
            var token = json['token'];
            final SharedPreferences prefs = await _prefs;
            await prefs.setString('token', token);

            emailController.clear();
            passwordController.clear();
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()));
          } else if (json['code'] == 1) {
            throw jsonDecode(response.body)['errors'];
          }
        } else {
          throw jsonDecode(response.body)["errors"] ?? "Unknown Error Occured";
        }
      } catch (error) {
        showError('Error', error.toString());
      }
    }
  }

  void showError(title, error) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              title,
              style: TextStyle(
                color: (title == 'Warning') ? Colors.amber : Colors.red,
              ),
            ),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error)],
          );
        });
  }

  var isLogin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(36),
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Text(
                      'Selamat Datang',
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: emailController,
                    obscureText: false,
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white54,
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.only(bottom: 15),
                        focusColor: Colors.white60),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        alignLabelWithHint: true,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black)),
                        fillColor: Colors.white54,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.only(bottom: 15),
                        focusColor: Colors.white60),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide.none)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent,
                          )),
                      onPressed: () {
                        login();
                      },
                      child: Text('Login',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ))),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide.none)),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.pinkAccent,
                          )),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      },
                      child: Text('Register',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ))),
                ]),
          ),
        ),
      ),
    );
  }
}
