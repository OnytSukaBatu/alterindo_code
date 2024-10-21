class Pengajuan {
  final int id;
  final String kode;
  final String nama;
  final int masuk;
  final int pulang;
  final int izin;
  final int cuti;
  final int maxBulan;
  final int maxTahun;
  final String divisi;

  Pengajuan({
    required this.id,
    required this.kode,
    required this.nama,
    required this.masuk,
    required this.pulang,
    required this.izin,
    required this.cuti,
    required this.maxBulan,
    required this.maxTahun,
    required this.divisi,
  });

  factory Pengajuan.fromJson(Map<String, dynamic> json) {
    return Pengajuan(
      id: json['id'],
      kode: json['Kode'],
      nama: json['Nama'],
      masuk: json['Masuk'],
      pulang: json['Pulang'],
      izin: json['Izin'],
      cuti: json['Cuti'],
      maxBulan: json['MaximalBulan'],
      maxTahun: json['MaximalTahun'],
      divisi: json['Divisi'] ?? '-',
    );
  }
}
