import 'dart:convert';
import 'package:http/http.dart' as myHttp;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/home-response.dart';


class HomeService {
  Future<HomeResponseModel?> getPresensi() async {
    // Ambil token dari SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("Token tidak ditemukan. Pengguna harus login kembali.");
      return null; // Jika tidak ada token, kembalikan null
    }

    try {
      var response = await myHttp.get(
        Uri.parse('https://absensidb.naar.my.id/api/presensi'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return HomeResponseModel.fromJson(json.decode(response.body));
      } else {
        print('Error dari server: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception terjadi: $e');
      return null;
    }
  }
}
