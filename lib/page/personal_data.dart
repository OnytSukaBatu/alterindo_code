import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class PersonalData extends StatefulWidget {
  final String nip;
  const PersonalData({
    super.key,
    required this.nip,
  });

  @override
  State<PersonalData> createState() => _PersonalDataState();
}

class _PersonalDataState extends State<PersonalData> {
  Logger logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  String nama = '';
  String noTelpon = '';
  String alamat = '';
  String jabatan = '';
  String divisi = '';
  String foto = '';

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
          nama = json[0]['Nama'] ?? 'User Is Null';
          alamat = json[0]['Alamat'] ?? 'Alamat Is Null';
          jabatan = json[0]['Jabatan'] ?? 'Jabatan Is Null';
          noTelpon = json[0]['HP'] ?? 'Nomer Telpon Is Null';
          divisi = json[0]['Divisi'] ?? 'Divisi Is Null';
          foto = json[0]['Foto'] ?? '';
        });
      } else {
        logger.t('Failed Load User Data');
      }
    } catch (e) {
      logger.t(e);
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
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: double.infinity),
            Text(
              'Personal Information',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIP',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.nip,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Nama',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nama,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No Telpon',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    noTelpon,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Alamat',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    alamat,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Jabatan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    jabatan,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Divisi',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    divisi,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 15),
                  Visibility(
                    visible: foto.isNotEmpty,
                    child: Container(
                      width: 150,
                      height: 200,
                      color: Colors.grey[200],
                      child: Image.memory(
                        base64Decode(foto),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
