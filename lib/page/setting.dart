import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/page/personal_data.dart';
import 'package:demo1/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Setting extends StatefulWidget {
  final String nip;
  const Setting({
    super.key,
    required this.nip,
  });

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Logger debugMessage = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  String nama = '';
  String jabatan = '';
  String foto = '';

  Future<void> delPref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('status', false);
    await prefs.setString('nip', '');
    await prefs.setString('device', '');
  }

  void fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://alterindo.com/hris/api.php?action=data_karyawan&id=${widget.nip}',
        ),
        headers: {
          'Authorization': 'Bearer ${API.token}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        setState(() {
          nama = json[0]['Nama'] ?? 'Gagal Mengambil User';
          jabatan = json[0]['Jabatan'] ?? '';
          foto = json[0]['Foto'] ?? '';
        });
      } else {
        debugMessage.t('Failed Load User Data');
      }
    } catch (e) {
      debugMessage.t(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Setting',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: foto.isEmpty
                        ? Center(
                            child: Text(
                              nama.isEmpty ? '' : nama[0],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image.memory(
                              base64Decode(foto),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          jabatan,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      delPref();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return PersonalData(
                      nip: widget.nip,
                    );
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12.5,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.5),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Personal Data',
                      style: GoogleFonts.poppins(),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12.5,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.5),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Versi',
                      style: GoogleFonts.poppins(),
                    ),
                    Spacer(),
                    Text(
                      'V 1.0.0',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
