import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/page/setting.dart';
import 'package:demo1/pages/absensi_page.dart';
import 'package:demo1/pages/history_cuti_page.dart';
import 'package:demo1/pages/history_izin_page.dart';
import 'package:demo1/pages/history_page.dart';
import 'package:demo1/pages/pengajuan_cuti_page.dart';
import 'package:demo1/pages/pengajuan_page.dart';
import 'package:demo1/widgets/item_interface.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:logger/web.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String nip;
  final String device;
  const HomePage({
    super.key,
    required this.nip,
    required this.device,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Logger debugMessage = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  int indexSlider = 0;
  String nama = 'USER';

  final List<Map<String, dynamic>> sliderItems = [
    {'color': Colors.blue[200], 'text': 'assets/bg2.jpg'},
    {'color': Colors.blue[300], 'text': 'assets/bg1.jpg'},
    {'color': Colors.blue[400], 'text': 'assets/bg3.jpg'},
  ];

  void getUserData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=login&id=${widget.nip}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        nama = json['Nama'] ?? 'User is Null';
      });
    } else {
      debugMessage.t('Gagal Mengambil User Data');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        viewportFraction: 1,
                        height: height * 0.3,
                        onPageChanged: (index, reason) {
                          setState(() => indexSlider = index);
                        },
                      ),
                      itemCount: sliderItems.length,
                      itemBuilder: (context, index, realIndex) {
                        final item = sliderItems[index];
                        return Container(
                          width: width,
                          color: item['color'],
                          child: item['text'] == ''
                              ? Center(
                                  child: Text(
                                    item['text'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  item['text'],
                                  fit: BoxFit.cover,
                                ),
                        );
                      },
                    ),
                    SizedBox(height: height * 0.075),
                  ],
                ),
                Positioned(
                  bottom: height * 0.0375,
                  child: Container(
                    width: width * 0.9,
                    height: height * 0.09,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 0.5,
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 15,
                          height: double.infinity,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return Setting(
                                    nip: widget.nip,
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'HAI, ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          nama,
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  ),
                ),
                // AnimatedSmoothIndicator(
                //   activeIndex: indexSlider,
                //   count: sliderItems.length,
                //   effect: const SwapEffect(
                //     dotColor: Colors.lightBlueAccent,
                //     activeDotColor: Colors.white,
                //     dotHeight: 7.5,
                //     dotWidth: 7.5,
                //   ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AbsensiPage(
                                  nip: widget.nip,
                                  device: widget.device,
                                ),
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'Absensi',
                            icon: Icons.more_time,
                            iconColor: Color(0xFF007bff),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return HistoryPage(
                                    nip: widget.nip,
                                  );
                                },
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'Histori\nAbsensi',
                            icon: Icons.history,
                            iconColor: Color(0xFF007bff),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PengajuanPage(
                                  nip: widget.nip,
                                ),
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'Pengajuan\nizin',
                            icon: Icons.send,
                            iconColor: Colors.blue,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return PengajuanCutiPage(
                                    nip: widget.nip,
                                  );
                                },
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'Pengajuan\nCuti',
                            icon: Icons.surfing,
                            iconColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return HistoryIzinPage(
                                    nip: widget.nip,
                                  );
                                },
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'History\nPengajuan\nIzin',
                            icon: Icons.post_add,
                            iconColor: Colors.blue,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return HistoryCutiPage(
                                    nip: widget.nip,
                                  );
                                },
                              ),
                            );
                          },
                          child: const ItemInterface(
                            text: 'History\nPengajuan\nCuti',
                            icon: Icons.post_add,
                            iconColor: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          width: width * 0.2,
                        ),
                        SizedBox(
                          width: width * 0.2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
