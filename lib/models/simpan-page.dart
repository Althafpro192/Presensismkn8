  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';

  import 'package:shared_preferences/shared_preferences.dart';

  class Simpanpresensi extends StatefulWidget {
    @override
    _SimpanpresensiState createState() => _SimpanpresensiState();
  }

  class _SimpanpresensiState extends State<Simpanpresensi> {
    final double officeLatitude = -8.2132148;
    final double officeLongitude = 113.4588733;
    final int maxDistance = 80;
    String timeString = "";
    bool isWithinDistance = false;
    bool _showNotification = false;
    String _notificationTitle = '';
    String _notificationMessage = '';
    Color _notificationColor = Colors.green;
Timer? _timer; 

     @override
  void initState() {
    super.initState();
    _startTimer(); // Mulai timer saat halaman diinisialisasi
    _checkLocationAndPresensi();  
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) { // Pastikan widget masih terpasang
        _sendPresensiRequest(); // Kirim permintaan presensi setiap menit
      }
    });
  }

  @override
  void dispose() {
    // Membatalkan timer untuk menghindari panggilan setState setelah dispose
    _timer?.cancel();
    super.dispose();
  }

    Future<void> _checkLocationAndPresensi() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showCustomNotification("Gagal Presensi", "Aktifkan GPS Anda untuk melanjutkan.", Colors.red);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          _showCustomNotification("Gagal Presensi", "Izin lokasi ditolak secara permanen.", Colors.red);
          return;
        }
      }

      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          officeLatitude,
          officeLongitude,
        );

        setState(() {
          isWithinDistance = distance <= maxDistance;
        });

        if (isWithinDistance) {
          await _sendPresensiRequest();  // Pastikan presensi hanya dilakukan jika dalam jarak
        } else {
          _showCustomNotification("Gagal Presensi", "Anda berada di luar lokasi sekolah.", Colors.red);
        }
      } catch (e) {
        _showCustomNotification("Gagal Presensi", "Terjadi kesalahan pada GPS: $e", Colors.red);
      }
    }

    Future<void> _sendPresensiRequest() async {
      try {
        // Mengambil token dari SharedPreferences
        final SharedPreferences pref = await SharedPreferences.getInstance();
        String? token = pref.getString("token");

        if (token == null || token.isEmpty) {
          _showCustomNotification("Gagal Presensi", "Token tidak ditemukan. Silakan login ulang.", Colors.red);
          return;
        }

        // Mengirim permintaan presensi dengan token di headers
        final response = await http.post(
          Uri.parse("https://absensidb.naar.my.id/api/presensi"),
          headers: {
            'Authorization': 'Bearer $token',  // Token diambil dari SharedPreferences
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'status': 'check-in',  // Sesuaikan dengan API
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = json.decode(response.body);
          _showCustomNotification("Sukses", data['message'], Colors.green);
        } else {
          final errorData = json.decode(response.body);
          _showCustomNotification("Gagal Presensi", errorData['message'] ?? "Error ${response.statusCode}", Colors.red);
        }
      } catch (error) {
        _showCustomNotification("Gagal Presensi", "Terjadi kesalahan: $error", Colors.red);
      }
    }

    void _showCustomNotification(String title, String message, Color color) {
      setState(() {
        _notificationTitle = title;
        _notificationMessage = message;
        _notificationColor = color;
        _showNotification = true;
      });

      Timer(Duration(seconds: 3), () {
        setState(() {
          _showNotification = false;
        });
      });
    }

    @override
    Widget build(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final isLandscape = size.width > size.height;

      // Sesuaikan ukuran elemen berdasarkan orientasi
      final double fontSize = isLandscape ? size.width * 0.05 : size.width * 0.14;
      final double buttonPadding = isLandscape ? size.width * 0.02 : size.width * 0.04;
      final double buttonFontSize = isLandscape ? size.width * 0.04 : size.width * 0.05;
      final double marginHorizontal = isLandscape ? size.width * 0.02 : size.width * 0.05;
      final double cardPaddingTop = isLandscape ? size.width * 0.1 : size.width * 0.15;

      return Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4197FB).withOpacity(1.0),
                    Color.fromARGB(160, 226, 227, 229).withOpacity(0.6),
                  ],
                  stops: [0.18, 1.0],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size.width * 0.04),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: marginHorizontal,
                              ),
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 700),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4197FB),
                                      Color.fromARGB(185, 225, 227, 230).withOpacity(0.3),
                                    ],
                                    stops: [0.18, 1.0],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(size.width * 0.04),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  size.width * 0.06,
                                  cardPaddingTop,
                                  size.width * 0.06,
                                  size.width * 0.05,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      timeString,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                            color: Color.fromRGBO(0, 0, 0, 0.25),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.04),
                                    Text(
                                      'Selamat datang\nKlik Tombol di Bawah ini',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        color: Colors.white,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFB1C5FF),
                                            Color(0xFF2D8EFF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(size.width * 0.08),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _checkLocationAndPresensi,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 0.3,
                                              vertical: buttonPadding),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(size.width * 0.08),
                                          ),
                                          textStyle: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            fontSize: buttonFontSize,
                                          ),
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            'Presensi',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.03),
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFC412).withOpacity(0.1),
                                            Color(0xFFFFC412),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(size.width * 0.08),
                                      ),
                                      // child: ElevatedButton(
                                      //   onPressed: () {
                                      //     // Logika tombol tambahan
                                      //   },
                                      //   style: ElevatedButton.styleFrom(
                                      //     backgroundColor: Colors.transparent,
                                      //     shadowColor: Colors.transparent,
                                      //     padding: EdgeInsets.symmetric(
                                      //         horizontal: size.width * 0.28,
                                      //         vertical: buttonPadding),
                                      //     shape: RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.circular(size.width * 0.08),
                                      //     ),
                                      //     textStyle: TextStyle(
                                      //       color: Colors.white,
                                      //       fontFamily: 'Poppins',
                                      //       fontWeight: FontWeight.bold,
                                      //       fontSize: buttonFontSize,
                                      //     ),
                                      //   ),
                                        // child: FittedBox(
                                        //   child: Text(
                                        //     'Tambah Izin',
                                        //     style: TextStyle(
                                        //       fontSize: 16,
                                        //       fontFamily: 'Poppins',
                                        //       fontWeight: FontWeight.bold,
                                        //       color: Colors.white,
                                        //     ),
                                        //   ),
                                        // ),
                                      // ),
                                    ),
                                    SizedBox(height: size.width * 0.05),
                                    RichText(
                                      text: TextSpan(
                                        text: 'Dikembangkan oleh ',
                                        style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontFamily: 'Poppins',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Raphael',
                                            style: TextStyle(
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
                            Positioned(
                              top: -size.width * 0.15,
                              child: CircleAvatar(
                                radius: size.width * 0.15,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage('images/logoabsen.png'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.width * 0.05),
                        Text(
                          'SMKN 8 JEMBER',
                          style: TextStyle(
                            fontSize: size.width * 0.06,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 4),
                                blurRadius: 4,
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showNotification)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(20.0),
                  color: _notificationColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _notificationTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _notificationMessage,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
