import 'dart:convert';
import 'package:demo1/widgets/pdf_reader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailCutiPage extends StatefulWidget {
  final String userOtorisasi;
  final String kodeUnik;
  final String keteranganOtorisasi;
  final String jenis;
  final String tanggalAwal;
  final String tanggalAkhir;
  final String uraian;
  final String foto;
  final String nama;
  final String pdf;
  final int otorisasi;
  const DetailCutiPage({
    super.key,
    required this.userOtorisasi,
    required this.kodeUnik,
    required this.keteranganOtorisasi,
    required this.jenis,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.uraian,
    required this.foto,
    required this.nama,
    required this.pdf,
    required this.otorisasi,
  });

  @override
  State<DetailCutiPage> createState() => _DetailCutiPageState();
}

class _DetailCutiPageState extends State<DetailCutiPage> {
  bool selected = false;
  bool photoS = false;

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
          'Detail Cuti',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 150),
              height: selected ? 120 : 50,
              color: widget.otorisasi == 0
                  ? Colors.yellow.withOpacity(0.5)
                  : widget.otorisasi == 1
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                widget.otorisasi == 0
                                    ? 'Pending'
                                    : widget.otorisasi == 1
                                        ? 'Disetujui'
                                        : 'Ditolak',
                                style: GoogleFonts.poppins(
                                  color: widget.otorisasi == 0
                                      ? Colors.yellow[800]
                                      : widget.otorisasi == 1
                                          ? Colors.blue
                                          : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: widget.userOtorisasi != '',
                            child: IconButton(
                              onPressed: () {
                                setState(() => selected = !selected);
                              },
                              icon: selected
                                  ? Icon(
                                      Icons.keyboard_arrow_up,
                                      color: widget.otorisasi == 0
                                          ? Colors.yellow[800]
                                          : widget.otorisasi == 1
                                              ? Colors.blue
                                              : Colors.red,
                                    )
                                  : Icon(
                                      Icons.keyboard_arrow_down,
                                      color: widget.otorisasi == 0
                                          ? Colors.yellow[800]
                                          : widget.otorisasi == 1
                                              ? Colors.blue
                                              : Colors.red,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.userOtorisasi == ''
                                        ? '?'
                                        : widget.userOtorisasi[0],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.userOtorisasi == ''
                                    ? 'Sedang Di Proses'
                                    : widget.userOtorisasi,
                                style: GoogleFonts.poppins(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kode Otorisasi',
                    style: GoogleFonts.poppins(),
                  ),
                  Text(
                    widget.kodeUnik == '' ? 'Tidak Ada Kode' : widget.kodeUnik,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Permohonan Izin',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.nama[0],
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.nama,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 10,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                  ),
                  Text(
                    'Keterangan Otorisasi',
                    style: GoogleFonts.poppins(),
                  ),
                  Text(
                    widget.keteranganOtorisasi == ''
                        ? 'Belum Ada Keterangan'
                        : widget.keteranganOtorisasi,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Jenis Cuti',
                    style: GoogleFonts.poppins(),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Colors.blue,
                      ),
                      Text(
                        widget.jenis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Tanggal Cuti',
                    style: GoogleFonts.poppins(),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),
                      Text(
                        ' ${widget.tanggalAwal}   s/d   ${widget.tanggalAkhir}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Uraian Izin',
                    style: GoogleFonts.poppins(),
                  ),
                  Text(
                    widget.uraian,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'File Pendukung',
                    style: GoogleFonts.poppins(),
                  ),
                  SizedBox(height: 5),
                  Visibility(
                    visible: widget.pdf.isNotEmpty,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return PdfReader(
                                pdfData: widget.pdf,
                                file: null,
                              );
                            },
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: const [
                          Icon(Icons.picture_as_pdf),
                          SizedBox(width: 10),
                          Text(
                            'Lihat File PDF',
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: widget.foto.isNotEmpty,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      height: photoS ? 365 : 50,
                      width: 315,
                      color: Colors.blue.withOpacity(0.5),
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Container(
                                  color: Colors.blue,
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      'Foto',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() => photoS = !photoS);
                                  },
                                  icon: selected
                                      ? const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: Colors.white,
                                        )
                                      : const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                        ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 315,
                              width: 315,
                              child: Image.memory(
                                base64Decode(widget.foto),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
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
}
