import 'dart:convert';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/models/class_history_izin.dart';
import 'package:demo1/pages/detail_izin_page.dart';
import 'package:demo1/widgets/data_history_izin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class HistoryIzinPage extends StatefulWidget {
  final String nip;
  const HistoryIzinPage({
    super.key,
    required this.nip,
  });

  @override
  State<HistoryIzinPage> createState() => _HistoryIzinPageState();
}

class _HistoryIzinPageState extends State<HistoryIzinPage> {
  final logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  bool refresh = false;

  DateTime dateNow = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
  DateTime firstDate = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));

  late Future<List<HistoryIzin>> dataHistoryIzin;

  String nama = '';
  String jabatan = '';

  int status = 3;

  void fetchUserData() async {
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
        jabatan = json['Jabatan'] ?? 'Jabatan Is NUll';
      });
    } else {
      logger.t('Failed Load User Data');
    }
  }

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
                dataHistoryIzin = fetchHistoryData();
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
                dataHistoryIzin = fetchHistoryData();
                setState(() => refresh = !refresh);
              });
            },
          ),
        );
      },
    );
  }

  Future<List<HistoryIzin>> fetchHistoryData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=data_pengajuan_izin&Kode=${widget.nip}&TanggalAwal=${DateFormat('yyyy-MM-dd').format(firstDate)}&TanggalAkhir=${DateFormat('yyyy-MM-dd').format(dateNow)}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      logger.t(response.body);
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => HistoryIzin.fromJson(json)).toList();
    } else {
      logger.t(response.body);
      throw Exception('Gagal Untuk Mengambil Data');
    }
  }

  void statusDynamiC() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    status = 3;
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Semua Status',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    status = 0;
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    status = 1;
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Disetujui',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    status = 2;
                  });
                  Navigator.pop(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      child: Text(
                        'Ditolak',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onRefresh() async {
    Future.delayed(Duration(seconds: 1));
    dataHistoryIzin = fetchHistoryData();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFirstDate();
    fetchUserData();
    dataHistoryIzin = fetchHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'List Izin',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
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
                                      DateFormat('yyyy-MM-dd')
                                          .format(firstDate),
                                      style: GoogleFonts.poppins(
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
                SizedBox(height: 10),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: InkWell(
                      onTap: statusDynamiC,
                      child: Row(
                        children: [
                          SizedBox(width: 15),
                          Text(
                            'Status: ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            status == 0
                                ? 'Pending'
                                : status == 1
                                    ? 'Disetujui'
                                    : status == 2
                                        ? 'Ditolak'
                                        : 'Semua Status',
                            style: GoogleFonts.poppins(),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_drop_down),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: FutureBuilder<List<HistoryIzin>>(
                future: dataHistoryIzin,
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
                        return Visibility(
                          visible: data.otorisasi == status || status == 3,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return DetailIzinPage(
                                      userOtorisasi: data.userOtorisasi,
                                      kodeUnik: data.kodeUnik,
                                      keteranganOtorisasi:
                                          data.keteranganOtorisasi,
                                      jenis: data.jenisIzin,
                                      tanggal: data.tanggal,
                                      uraian: data.keterangan,
                                      foto: data.foto,
                                      nama: nama,
                                      pdf: data.dokumen,
                                      otorisasi: data.otorisasi,
                                    );
                                  },
                                ),
                              );
                            },
                            child: DataHistoryIzin(
                              tanggal: data.tanggal,
                              jenis: data.jenisIzin,
                              keterangan: data.keterangan,
                              userOtorisasi: data.userOtorisasi,
                              otorisasi: data.otorisasi,
                              keteranganOtorisasi: data.keteranganOtorisasi,
                              kodeUnik: data.kodeUnik,
                              foto: data.foto,
                              dokumen: data.dokumen,
                              nama: nama,
                            ),
                          ),
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
