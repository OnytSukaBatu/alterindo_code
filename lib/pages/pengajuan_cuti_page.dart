import 'dart:convert';
import 'dart:io';
import 'package:demo1/data/api_token.dart';
import 'package:demo1/widgets/pdf_reader.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'package:demo1/models/class_pengajuan.dart';
import 'package:demo1/widgets/bottom_notif.dart';
import 'package:demo1/widgets/loading.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class PengajuanCutiPage extends StatefulWidget {
  final String nip;
  const PengajuanCutiPage({
    super.key,
    required this.nip,
  });

  @override
  State<PengajuanCutiPage> createState() => _PengajuanCutiPageState();
}

class _PengajuanCutiPageState extends State<PengajuanCutiPage> {
  final logger = Logger(
    printer: PrettyPrinter(
      lineLength: 60,
    ),
  );

  TextEditingController ketController =
      TextEditingController(text: '''Saya Mengajukan Cuti ..
Dikarenakan ..''');

  late Future<List<Pengajuan>> dataIzin;

  File? foto;
  File? file;

  bool selected = false;
  DateTime dateNow = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));
  DateTime lastDate = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));

  String izin = 'Pilih Disini';
  String izinCode = '0000';

  String nama = '';
  String jabatan = '';

  int sisaCuti = 0;

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

  void fetchSisaCuti() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=sisa_cuti&id=${widget.nip}',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        sisaCuti = json['Cuti'] ?? -1;
      });
    } else {
      logger.t('Failed Load User Data');
    }
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
              setState(() => dateNow = newDateTime);
            },
          ),
        );
      },
    );
  }

  void lastDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          width: double.infinity,
          child: CupertinoDatePicker(
            backgroundColor: Colors.transparent,
            initialDateTime: lastDate,
            use24hFormat: true,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() => lastDate = newDateTime);
            },
          ),
        );
      },
    );
  }

  void deleteContext(
    String title,
    String subtitle,
    void Function() fun,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 25),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              textAlign: TextAlign.center,
              subtitle,
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.grey,
            ),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        child: Center(
                          child: Text(
                            'TIDAK',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: fun,
                      child: SizedBox(
                        child: Center(
                          child: Text(
                            'YA',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                          ),
                        ),
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

  Future<List<Pengajuan>> fetchHistoryData() async {
    final response = await http.get(
      Uri.parse(
        'https://alterindo.com/hris/api.php?action=data_cuti',
      ),
      headers: {
        'Authorization': 'Bearer ${API.token}',
      },
    );
    if (response.statusCode == 200) {
      logger.t(response.body);
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Pengajuan.fromJson(json)).toList();
    } else {
      logger.t(response.body);
      throw Exception('Gagal Untuk Mengambil Data');
    }
  }

  void pilihIzin() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Pilih Jenis Cuti',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: FutureBuilder<List<Pengajuan>>(
                  future: dataIzin,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Gagal Untuk Mengambil Data',
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                izin = data.nama;
                                izinCode = data.kode;
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
                                    data.nama,
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
            ],
          ),
        );
      },
    );
  }

  void kirimPengajuan(
    String tanggalAwal,
    String tanggalAkhir,
    String kode,
    String jenis,
    String keterangan,
    File? foto,
    File? file,
  ) async {
    final formData = FormData.fromMap({
      'TanggalAwal': tanggalAwal,
      'TanggalAkhir': tanggalAkhir,
      'Kode': kode,
      'Jenis': jenis,
      'Keterangan': keterangan,
      'foto': await MultipartFile.fromFile(
        foto!.path,
        filename: '${DateTime.now()}.jpg',
      ),
      'dokumen': file == null
          ? ''
          : await MultipartFile.fromFile(
              file.path,
              filename: '${DateTime.now()}.pdf',
            )
    });
    if (mounted) {
      loading(context: context);
    }

    final response = await Dio().post(
      'https://alterindo.com/hris/api.php?action=insert_cuti',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${API.token}',
        },
      ),
    );

    if (mounted) {
      Navigator.pop(context);
      setState(() {
        foto = null;
        file = null;
        izinCode == '0000';
        izin = 'Pilih Disini';
        ketController = TextEditingController(text: '''Saya Mengajukan Cuti ..
Dikarenakan ..''');
      });
      bottomNotif(
        context: context,
        title: 'Pengajuan Cuti Berhasil',
        subtitle: 'menunggu otorisasi',
        icon: Icons.verified,
        image: '',
      );
    }
    logger.t('''Status Code: ${response.statusCode}
Response Body: ${response.data}''');
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    String filePath = result.files.single.path!;
    setState(() => file = File(filePath));
  }

  void imagePicker() async {
    final imageData =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageData == null) return;
    setState(() {
      foto = File(imageData.path);
    });
  }

  void attachFileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (foto != null) {
                      return deleteContext(
                        'Foto Sudah Ada!',
                        'Tindakan Ini Akan Menggati\nFoto Yang Ada',
                        imagePicker,
                      );
                    } else {
                      imagePicker();
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'FOTO',
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (file != null) {
                      return deleteContext(
                        'PDF Sudah Ada!',
                        'Tindakan Ini Akan Menggati\nFile PDF Yang Ada',
                        pickFile,
                      );
                    } else {
                      pickFile();
                    }
                  },
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'PDF',
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.5),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    height: 50,
                    child: const Center(
                      child: Text(
                        'BATAL',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchSisaCuti();
    dataIzin = fetchHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (izinCode != '0000' ||
                foto != null ||
                file != null ||
                ketController.text !=
                    '''Saya Mengajukan Cuti ..
Dikarenakan ..''') {
              deleteContext(
                'Keluar Halaman?',
                'Tindakan Ini Akan Menghapus\nData Yang Kamu Tambahkan',
                () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.close),
        ),
        title: Text(
          'Pengajuan Cuti',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: attachFileDialog,
            icon: const Icon(Icons.attachment),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permohoman Cuti',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedContainer(
                              height: selected ? 290 : 50,
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.centerRight,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            'Data Permohonan Cuti',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() => selected = !selected);
                                        },
                                        icon: selected
                                            ? const Icon(
                                                Icons.keyboard_arrow_up,
                                              )
                                            : const Icon(
                                                Icons.keyboard_arrow_down,
                                              ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Center(
                                        child: SingleChildScrollView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'NIP',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(
                                                  widget.nip,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: double.infinity,
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Nama',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(
                                                  nama,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: double.infinity,
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Jabatan',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(
                                                  jabatan,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: double.infinity,
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Sisa Cuti',
                                                  style: GoogleFonts.poppins(),
                                                ),
                                                Text(
                                                  sisaCuti == -1
                                                      ? 'Tidak Dapat Mengambil Data'
                                                      : sisaCuti.toString(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Jenis',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: pilihIzin,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 28,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                izin,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue[800],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 8,
                    color: Colors.grey[300],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Tanggal Awal Izin',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: datePicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 28,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('dd MMM yyyy').format(dateNow),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue[800],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 8,
                    color: Colors.grey[300],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Tanggal Akhir Izin',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: lastDatePicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 28,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('dd MMM yyyy').format(lastDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.blue[800],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 8,
                    color: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keteragan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: ketController,
                          minLines: 1,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tulis Disini',
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: file != null || foto != null,
                    child: Container(
                      height: 8,
                      color: Colors.grey[300],
                    ),
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: file != null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return PdfReader(pdfData: '', file: file);
                              },
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf),
                            SizedBox(width: 10),
                            Text('File PDF Telah Terkait'),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                deleteContext(
                                  'Hapus PDF?',
                                  'Apakah Kamu Yakin\nMenghapus file PDF?',
                                  () {
                                    setState(() => file = null);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: foto != null,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          foto != null ? Image.file(foto!) : SizedBox(),
                          IconButton(
                            onPressed: () {
                              deleteContext(
                                'Hapus Gambar?',
                                'Apa Kamu Yakin Ingin\nMenghapus Gambar',
                                () {
                                  setState(() => foto = null);
                                  Navigator.pop(context);
                                },
                              );
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.75),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: InkWell(
              onTap: () {
                if (izinCode == '0000') {
                  bottomNotif(
                    context: context,
                    title: 'Jenis Izin Kosong!',
                    subtitle: 'Pilih Jenis Izin',
                    icon: Icons.close,
                    image: '',
                  );
                } else if (foto == null) {
                  bottomNotif(
                    context: context,
                    title: 'Foto Kosong!',
                    subtitle: 'Foto Diperlukan',
                    icon: Icons.close,
                    image: '',
                  );
                } else {
                  kirimPengajuan(
                    DateFormat('yyyy-MM-dd').format(dateNow),
                    DateFormat('yyyy-MM-dd').format(lastDate),
                    widget.nip,
                    izinCode,
                    ketController.text,
                    foto,
                    file,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'AJUKAN CUTI',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
}
