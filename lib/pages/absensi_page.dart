import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/pages/history_page.dart';
import 'package:demo1/widgets/bottom_notif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;

class AbsensiPage extends StatefulWidget {
  final String nip;
  final String device;
  const AbsensiPage({
    super.key,
    required this.nip,
    required this.device,
  });

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  final formatDateTimeNow = DateFormat('dd-MM-yyyy').format(
    tz.TZDateTime.now(
      tz.getLocation('Asia/Jakarta'),
    ),
  );

  late Timer timer;
  late tz.TZDateTime currentTime;
  late double height;

  double latCor = 1.2878;
  double longCor = 103.8666;

  bool visi = false;

  String jamMasuk = '';
  String jamPulang = '';
  String terlambat = '';
  String toleransi = '';
  String shift = '';

  void updateTime(Timer timer) {
    setState(() {
      currentTime = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
    });
  }

  void scanQR() async {
    try {
      String barcodeScanRes;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        false,
        ScanMode.QR,
      );
      if (mounted) {
        if (barcodeScanRes != '-1') {
          addData(barcodeScanRes);
        }
      }
    } on PlatformException {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Function Device Not Ready'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> addData(String data) async {
    final date = DateFormat('yyyy-MM-dd').format(currentTime);
    final time = DateFormat('HH:mm').format(currentTime);
    final body = {
      "Token": data,
      "Kode": widget.nip,
      "Tanggal": date,
      "JamMasuk": time,
      "Device": widget.device,
    };
    final uri = Uri.parse(
      'https://alterindo.com/hris/api.php?action=insert_absen',
    );
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    final responseData = jsonDecode(response.body);
    logger.t(response.body);
    if (responseData.containsKey('message')) {
      final message = responseData['message'];
      if (message == 'QR Kadaluarsa') {
        if (mounted) {
          bottomNotif(
            context: context,
            title: 'QR Kadaluarsa Silahkan Coba Lagi',
            subtitle: '',
            icon: Icons.close,
            image: 'assets/kadaluarsa.jpeg',
          );
        }
      } else if (message == 'Anda Sudah Absen') {
        if (mounted) {
          bottomNotif(
            context: context,
            title: 'Anda Sudah Absen',
            subtitle: '',
            icon: Icons.warning,
            image: '',
          );
        }
      } else if (message == 'Absen Berhasil') {
        if (mounted) {
          bottomNotif(
            context: context,
            title: 'Selamat Bekerja',
            subtitle: time,
            icon: Icons.verified,
            image: '',
          );
        }
      } else if (message == 'Absen Pulang Berhasil') {
        if (mounted) {
          bottomNotif(
            context: context,
            title: 'Hati Hati Di Jalan',
            subtitle: time,
            icon: Icons.directions_walk,
            image: '',
          );
        }
      } else if (message == 'Anda Sudah Absen Pulang') {
        if (mounted) {
          bottomNotif(
            context: context,
            title: 'Anda Sudah Absen Pulang',
            subtitle: '',
            icon: Icons.close,
            image: '',
          );
        }
      } else {
        if (mounted) {
          bottomNotif(
            context: context,
            title: response.body,
            subtitle: response.statusCode.toString(),
            icon: Icons.close,
            image: '',
          );
        }
      }
      fetchAbsensData();
    } else {
      logger.t(response.body);
    }
    logger.t(response.body);
  }

  void fetchAbsensData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=data_absen&id=${widget.nip}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        jamMasuk = json['JamMasuk'] ?? '';
        jamPulang = json['JamPulang'] ?? '';
        terlambat = json['Terlambat'] ?? '';
        toleransi = json['Toleransi'] ?? '';
      });
    } else {
      throw Exception('Failed to load user');
    }
  }

  fetchShiftData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=data_shift&id=${widget.nip}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        shift = json['Shift'];
      });
    } else {
      throw Exception('Failed to load shift');
    }
  }

  Future<Position> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error('Location Sevice are disable');
      if (mounted) {
        bottomNotif(
          context: context,
          title: 'Izin Lokasi Ditolak',
          subtitle: 'Beri Izin Aplikasi!',
          icon: Icons.warning,
          image: '',
        );
      }
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      Future.error('Lokasi Diblock');
      if (mounted) {
        bottomNotif(
          context: context,
          title: 'Izin Lokasi Di Block',
          subtitle: 'Periksa Izin Aplikasi!',
          icon: Icons.warning,
          image: '',
        );
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void mapLoad() async {
    await getLocation().then((value) {
      setState(() {
        latCor = value.latitude;
        longCor = value.longitude;
      });
    });
    await Future.delayed(
      const Duration(seconds: 1),
    );
    setState(() => visi = true);
  }

  @override
  void initState() {
    super.initState();
    fetchAbsensData();
    fetchShiftData();
    currentTime = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
    timer = Timer.periodic(const Duration(seconds: 1), updateTime);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mapLoad();
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Absensi Karyawan',
              style: GoogleFonts.poppins(
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: () {
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
              icon: const Icon(Icons.history),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.425),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: Icon(Icons.more_time),
                                ),
                                Text(
                                  '${currentTime.hour.toString().padLeft(2, '0')}:'
                                  '${currentTime.minute.toString().padLeft(2, '0')}:'
                                  '${currentTime.second.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                  ),
                                ),
                                Icon(
                                  Icons.info,
                                  color: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width - 25,
                          color: Colors.grey,
                          child: visi
                              ? content()
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => visi = false);
                            mapLoad();
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.cases_rounded,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    ' Shift $shift',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey.withOpacity(0.2),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(2),
                                            child: Icon(
                                              Icons.exit_to_app,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: Container(
                                            height: 35,
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(2),
                                            child: Icon(
                                              Icons.exit_to_app,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jamMasuk.isEmpty ? '--:--' : jamMasuk,
                                          style: GoogleFonts.poppins(
                                            color: Colors.blue,
                                            fontSize: 24,
                                          ),
                                        ),
                                        Text(
                                          toleransi.isNotEmpty
                                              ? toleransi
                                              : terlambat.isNotEmpty
                                                  ? terlambat
                                                  : 'Normal Absensi QR Tgl $formatDateTimeNow',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          jamPulang.isEmpty
                                              ? '--:--'
                                              : jamPulang,
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 24,
                                          ),
                                        ),
                                        Text(
                                          'Normal Absensi QR Tgl $formatDateTimeNow',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: scanQR,
            child: Container(
              height: 65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'ABSEN',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget content() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(latCor, longCor),
        initialZoom: 17.5,
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(latCor, longCor),
              child: const Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SizedBox.shrink(),
                  Positioned(
                    bottom: 12.5,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
