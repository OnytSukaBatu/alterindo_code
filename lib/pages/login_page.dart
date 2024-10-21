import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/pages/home_page.dart';
import 'package:demo1/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Logger debugMessage = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  TextEditingController nipController = TextEditingController();
  TextEditingController aktivasiController = TextEditingController();

  bool status = false;
  late String nip;
  late String device;

  Future<void> setPref(String nipInput, String deviceInput) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('status', true);
    await prefs.setString('nip', nipInput);
    await prefs.setString('device', deviceInput);
  }

  Future<void> getPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      status = prefs.getBool('status') ?? false;
      nip = prefs.getString('nip') ?? '';
      device = prefs.getString('device') ?? '';
    });
  }

  void login(String nipInput, String kodeAktivasi) async {
    loading(context: context);
    final response = await http.post(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=login',
      ),
      body: jsonEncode({
        'NIP': nipInput,
        'KodeAktivasi': kodeAktivasi,
      }),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = jsonDecode(response.body);
        String dataNip = data['NIP'] ?? '';
        String dataDevice = data['Device'] ?? '';
        setPref(dataNip, dataDevice);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                nip: dataNip,
                device: dataDevice,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          debugMessage.t(e);
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
        debugMessage.t(response.body);
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    if (status) {
      return HomePage(
        nip: nip,
        device: device,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                scale: 2.5,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: nipController,
                decoration: InputDecoration(
                  hintText: 'NIP',
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: aktivasiController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'AKTIVASI',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () {
                  login(
                    nipController.text,
                    aktivasiController.text,
                  );
                },
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
