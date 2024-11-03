class HomeResponseModel {
  List<Attendance>? attendances;

  HomeResponseModel({this.attendances});

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      attendances: (json['data'] as List<dynamic>?)
          ?.map((attendanceJson) => Attendance.fromJson(attendanceJson))
          .toList(),
    );
  }
}

class Attendance {
  int? id;
  String? siswaId;
  String? tanggal;
  String? keterangan;
  String? waktuDatang;
  String? waktuPulang;

  Attendance({
    this.id,
    this.siswaId,
    this.tanggal,
    this.keterangan,
    this.waktuDatang,
    this.waktuPulang,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int?,
      siswaId: json['siswa_id'] as String?,
      tanggal: json['tanggal'] as String?,
      keterangan: json['keterangan'] as String?,
      waktuDatang: json['waktu_datang'] as String?,
      waktuPulang: json['waktu_pulang'] as String?,
    );
  }
}
