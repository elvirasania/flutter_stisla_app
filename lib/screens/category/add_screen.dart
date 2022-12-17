import 'dart:async';
import 'dart:convert';
import 'package:flutter_stisla_app/network/api_urls.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_stisla_app/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController nameController = TextEditingController();

  void addData() async {
    var prefs = await _prefs;
    var token = prefs.getString('token');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    if (nameController.text == '') {
      showError('Warning', 'Name harus diisi');
    } else {
      try {
        var url = Uri.parse(ApiUrls().baseUrl + ApiUrls().category);
        Map body = {
          'name': nameController.text.trim(),
        };
        final response =
            await http.post(url, body: jsonEncode(body), headers: headers);

        print(response.statusCode);
        if (response.statusCode == 201) {
          nameController.clear();
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Center(
            child: Column(children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(0),
                child: const Text(
                  'Tambah Kategori',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: nameController,
                obscureText: false,
                decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    fillColor: Colors.white54,
                    hintText: 'Nama Kategori',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.only(bottom: 15),
                    focusColor: Colors.white60),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.pinkAccent,
                      )),
                  onPressed: () {
                    addData();
                  },
                  child: const Text('Tambah',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ))),
              const SizedBox(
                height: 20,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
