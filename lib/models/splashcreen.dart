

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as myHttp;

import 'package:shared_preferences/shared_preferences.dart';

import '../api/login-response.dart';
import 'sampah.dart';




class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
_checkToken();
  }

   Future<void> _checkToken() async {
    // Tunggu selama 3 detik sebelum melakukan pengecekan token
    await Future.delayed(Duration(seconds: 3));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    // Navigasi ke HomePage jika ada token, atau ke LoginPage jika tidak ada
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(FadePageRoute(page: DashboardPage ()));
    } else {
      Navigator.of(context).pushReplacement(FadePageRoute(page: LoginPage()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.white],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('images/logo.png', height: 100),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                    'SMKN 8 JEMBER',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 255, 253, 253),
                      shadows: [
                        Shadow(
                          offset: Offset(0, 4),
                          blurRadius: 4,
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class FadePageRoute extends PageRouteBuilder {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isVisible = false;
  String _loginMessage = '';
  Color _messageColor = Colors.green;
  bool _obscurePassword = true;

  late Future<String> _name, _token;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
  String tokenStr = await token;
  String nameStr = await name;
  if (tokenStr != "" && nameStr != "") {
    Future.delayed(Duration(seconds: 1), () async {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardPage())).then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    });
  }
}


 Future login(String identifier, String password) async {
  // Validasi apakah NISN atau Password kosong
  if (identifier.isEmpty || password.isEmpty) {
    setState(() {
      _loginMessage = "NISN dan Password tidak boleh kosong.";
      _messageColor = Colors.red;
      _isVisible = true;
    });
    return; // Hentikan proses jika validasi gagal
  }

  setState(() {
    _isLoading = true;
    _isVisible = false;
    _loginMessage = '';
  });

  LoginResponseModel? loginResponseModel;
  Map<String, String> body = {
    "identifier": identifier,
    "password": password,
  };

  var response = await myHttp.post(
    Uri.parse('https://absensidb.naar.my.id/api/auth/login'),
    body: body,
  );

  if (response.statusCode == 401) {
  setState(() {
    _loginMessage = "NISN atau Password salah";
    _messageColor = Colors.red;
    _isVisible = true;
  });
} else if (response.statusCode == 200) {
  // Coba untuk mengurai JSON respons
  var responseData = json.decode(response.body);

  // Cek apakah token dan data ada
  if (responseData['token'] != null && responseData['data'] != null) {
    loginResponseModel = LoginResponseModel.fromJson(responseData);

    // Pastikan data tidak null dan beri nilai default jika nama tidak tersedia
    String userName = loginResponseModel.data?.name ?? 'Anonymous';
    String token = loginResponseModel.token ?? '';

    saveUser(token, userName);  // Simpan token dan nama pengguna
  } else {
    // Jika token atau data null, tampilkan pesan error
    setState(() {
      _loginMessage = "Data tidak di temukan. Coba lagi.";
      _messageColor = Colors.red;
      _isVisible = true;
    });
  }
} else {
  // Menangani status kode selain 200 dan 401
  setState(() {
    _loginMessage = "Gagal masuk, coba lagi nanti.";
    _messageColor = Colors.red;
    _isVisible = true;
  });
}

  setState(() {
    _isLoading = false;
  });
}

  Future saveUser(String token, String name) async {
  try {
    final SharedPreferences pref = await _prefs;
    pref.setString("name", name.isNotEmpty ? name : "Anonymous");
    pref.setString("token", token);
    if (mounted) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => DashboardPage()))
          .then((value) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  } catch (err) {
    print('ERROR: ' + err.toString());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.white],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                 child: Center( // Tambahkan Center di sini
      child: Container(
        constraints: BoxConstraints(maxWidth: 600), // Batas maksimal lebar 600
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Image.asset('images/kiri.png'),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Image.asset('images/kanan.png'),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.only(top: 0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 17),
                            Text(
                              'Selamat datang! 👋',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Masuk dan mulai langkahmu.',
                              style: TextStyle(fontSize: 13),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _usernameController,
                              keyboardType: TextInputType.number,   
                              decoration: InputDecoration(
                                labelText: 'NISN',
                                hintText: 'Masukan NISN',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Color.fromRGBO(246, 246, 246, 1),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Masukan Password Anda',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Color.fromRGBO(246, 246, 246, 1),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [Color(0xFFB1C5FF), Color(0xFF2D8EFF)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  login(
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(vertical: 11.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Masuk',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                text: 'Developed by ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Raphael',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF2D8EFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              ))),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Visibility(
            visible: _isVisible,
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(top: 0),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: _messageColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              height: 80.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _loginMessage
                    .split('\n')
                    .map((line) => Text(
                          line,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

