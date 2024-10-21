import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/models/class_history.dart';
import 'package:demo1/widgets/data_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;

class HistoryPage extends StatefulWidget {
  final String nip;
  const HistoryPage({
    super.key,
    required this.nip,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  late Future<List<History>> dataHistory;

  DateTime dateNow = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
  DateTime firstDate = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));

  bool refresh = false;

  void getFirstDate() {
    DateTime newDate = DateTime(dateNow.year, dateNow.month, 1);
    setState(() {
      firstDate = newDate;
    });
  }

  void firstDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          width: double.infinity,
          child: CupertinoDatePicker(
            backgroundColor: Colors.transparent,
            initialDateTime: firstDate,
            use24hFormat: true,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                firstDate = newDateTime;
                dataHistory = fetchHistoryData();
                setState(() => refresh = !refresh);
              });
            },
          ),
        );
      },
    );
  }

  void datePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          width: double.infinity,
          child: CupertinoDatePicker(
            backgroundColor: Colors.transparent,
            initialDateTime: dateNow,
            use24hFormat: true,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                dateNow = newDateTime;
                dataHistory = fetchHistoryData();
                setState(() => refresh = !refresh);
              });
            },
          ),
        );
      },
    );
  }

  Future<List<History>> fetchHistoryData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=data_absen_history&id=${widget.nip}&TanggalAwal=${DateFormat('yyyy-MM-dd').format(firstDate)}&TanggalAkhir=${DateFormat('yyyy-MM-dd').format(dateNow)}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      logger.t(response.body);
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => History.fromJson(json)).toList();
    } else {
      logger.t(response.body);
      throw Exception('Gagal Untuk Mengambil Data');
    }
  }

  Future<void> onRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    dataHistory = fetchHistoryData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFirstDate();
    dataHistory = fetchHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          'Histori Absensi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 0.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Awal',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              firstDatePicker();
                            },
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(firstDate),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: double.infinity),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Akhir',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              datePicker();
                            },
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(dateNow),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: FutureBuilder<List<History>>(
                future: dataHistory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    logger.t(snapshot.error);
                    return Center(
                      child: Text(
                        'Gagal Untuk Mengambil Data',
                        style: GoogleFonts.poppins(),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data![index];
                        return DataHistory(
                          tanggal: data.tanggal,
                          keterangan: data.keterangan,
                          jamMasuk: data.jamMasuk,
                          jamPulang: data.jamPulang,
                          ketBawah: data.status == 1
                              ? '${data.keterangan} ${data.terlambat != '' ? data.terlambat : data.toleransi != '' ? data.toleransi : 'Normal Absensi'}'
                              : data.keterangan,
                          shift: data.namaShift,
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('Tidak Ada Data Yang Ditemukan'),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
