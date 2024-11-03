import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModel({
    required this.message,
    required this.data,
    required this.token,
  });

  String message;
  Data? data; // Nullable karena data bisa null
  String token;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        message: json["message"] ?? '',
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        token: json["token"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
        "token": token,
      };
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.siswaId,
    required this.guruId,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  String name;
  String email;
  int? siswaId; // Nullable jika bisa null
  int? guruId; // Nullable jika bisa null
  DateTime createdAt;
  DateTime updatedAt;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"] ?? '', // Menyediakan nilai default jika null
        email: json["email"] ?? '',
        siswaId: json["siswa_id"],
        guruId: json["guru_id"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(), // Set default DateTime jika null
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(), // Set default DateTime jika null
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "siswa_id": siswaId,
        "guru_id": guruId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
