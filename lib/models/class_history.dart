class History {
  final String karyawan;
  final String tanggal;
  final int status;
  final String jamMasuk;
  final String jamPulang;
  final String terlambat;
  final String toleransi;
  final String keterangan;
  final String namaShift;

  History({
    required this.karyawan,
    required this.tanggal,
    required this.status,
    required this.jamMasuk,
    required this.jamPulang,
    required this.terlambat,
    required this.toleransi,
    required this.keterangan,
    required this.namaShift,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      karyawan: json['Karyawan'] ?? 'Data Karyawan Null',
      tanggal: json['Tanggal'] ?? 'Data Tanggal Null',
      status: json['Status'] ?? 0,
      jamMasuk: json['JamMasuk'] ?? '--:--',
      jamPulang: json['JamPulang'] ?? '--:--',
      terlambat: json['Terlambat'] ?? 'Data Terlambat Null',
      toleransi: json['Toleransi'] ?? 'Data Toleransi Null',
      keterangan: json['Keterangan'] ?? 'Data Keterangan Null',
      namaShift: json['NamaShift'] ?? 'Data NamaShift Null',
    );
  }
}
