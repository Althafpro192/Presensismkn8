import 'dart:convert';

SavePresensiResponseModel savePresensiResponseModelFromJson(String str) =>
    SavePresensiResponseModel.fromJson(json.decode(str));

String savePresensiResponseModelToJson(SavePresensiResponseModel data) =>
    json.encode(data.toJson());

class SavePresensiResponseModel {
  SavePresensiResponseModel({
    required this.success,
    this.data, // data bisa null
    required this.message,
  });

  bool success;
  Data? data; // Data bersifat nullable karena bisa null
  String message;

  factory SavePresensiResponseModel.fromJson(Map<String, dynamic> json) =>
      SavePresensiResponseModel(
        success: json["success"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null, // Cek null pada data
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(), // Cek null pada data untuk menghindari error
        "message": message,
      };
}

class Data {
  Data({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.masuk,
    this.pulang, // pulang dapat null
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String userId;
  DateTime tanggal;
  String masuk;
  String? pulang; // pulang dapat null
  DateTime createdAt;
  DateTime updatedAt;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        userId: json["user_id"].toString(),
        tanggal: DateTime.parse(json["tanggal"]),
        masuk: json["masuk"].toString(),
        pulang: json["pulang"]?.toString(), // Cek null pada pulang
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "tanggal": tanggal.toIso8601String().split('T').first, // Format tanggal saja
        "masuk": masuk,
        "pulang": pulang,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
