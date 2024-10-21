class HistoryIzin {
  final String tanggal;
  final String jenis;
  final String keterangan;
  final String userOtorisasi;
  final int otorisasi;
  final String keteranganOtorisasi;
  final String kodeUnik;
  final String foto;
  final String dokumen;
  final String jenisIzin;

  HistoryIzin({
    required this.tanggal,
    required this.jenis,
    required this.keterangan,
    required this.userOtorisasi,
    required this.otorisasi,
    required this.keteranganOtorisasi,
    required this.kodeUnik,
    required this.foto,
    required this.dokumen,
    required this.jenisIzin,
  });

  factory HistoryIzin.fromJson(Map<String, dynamic> json) {
    return HistoryIzin(
      tanggal: json['Tanggal'] ?? '',
      jenis: json['Jenis'] ?? '',
      keterangan: json['Keterangan'] ?? '',
      userOtorisasi: json['UserOtorisasi'] ?? '',
      otorisasi: json['Otorisasi'] ?? 0,
      keteranganOtorisasi: json['KeteranganOtorisasi'] ?? '',
      kodeUnik: json['KodeUnik'] ?? '',
      foto: json['Foto'] ?? '',
      dokumen: json['Dokumen'] ?? '',
      jenisIzin: json['JenisIzin'] ?? '',
    );
  }
}
