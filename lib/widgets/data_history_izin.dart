import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataHistoryIzin extends StatefulWidget {
  final String tanggal;
  final String jenis;
  final String keterangan;
  final String userOtorisasi;
  final int otorisasi;
  final String keteranganOtorisasi;
  final String kodeUnik;
  final String foto;
  final String dokumen;
  final String nama;
  const DataHistoryIzin({
    super.key,
    required this.tanggal,
    required this.jenis,
    required this.keterangan,
    required this.userOtorisasi,
    required this.otorisasi,
    required this.keteranganOtorisasi,
    required this.kodeUnik,
    required this.foto,
    required this.dokumen,
    required this.nama,
  });

  @override
  State<DataHistoryIzin> createState() => _DataHistoryIzinState();
}

class _DataHistoryIzinState extends State<DataHistoryIzin> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.keterangan,
                  style: GoogleFonts.poppins(),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 17.5,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.tanggal,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.directions_walk,
                      size: 17.5,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.jenis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: widget.otorisasi == 0
                        ? Colors.yellow.withOpacity(0.5)
                        : widget.otorisasi == 1
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      widget.otorisasi == 0
                          ? 'Pending'
                          : widget.otorisasi == 1
                              ? 'ACC'
                              : 'Ditolak',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: widget.otorisasi == 0
                            ? Colors.yellow[800]
                            : widget.otorisasi == 1
                                ? Colors.green
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.nama,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey,
        ),
      ],
    );
  }
}
