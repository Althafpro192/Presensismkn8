// import 'dart:convert';
// import 'package:http/http.dart' as myHttp;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../api/login-response.dart';

// class LoginService {
//   Future<void> checkToken(Function onValidToken, Function onInvalidToken) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("token");

//     if (token != null && token.isNotEmpty) {
//       onValidToken();
//     } else {
//       onInvalidToken();
//     }
//   }

//   Future<void> login(String identifier, String password, Function onSuccess, Function onError) async {
//     Map<String, String> body = {
//       "identifier": identifier,
//       "password": password,
//     };

//     var response = await myHttp.post(
//       Uri.parse('https://absensidb.naar.my.id/api/auth/login'),
//       body: body,
//     );

//     if (response.statusCode == 401) {
//       onError("NISN atau password salah");
//     } else if (response.statusCode == 200) {
//       LoginResponseModel loginResponseModel = LoginResponseModel.fromJson(json.decode(response.body));
//       await saveUser(loginResponseModel.token ?? '', loginResponseModel.data!.name ?? '');
//       onSuccess();
//     } else {
//       onError("Gagal masuk, coba lagi nanti.");
//     }
//   }

//   Future<void> saveUser(String token, String name) async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.setString("name", name.isNotEmpty ? name : "Anonymous");
//     pref.setString("token", token);
//   }
// }
