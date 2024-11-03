import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;
import 'dart:convert';

import 'simpan-page.dart';
import 'splashcreen.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic>? _attendanceData;
  int totalHadir = 0;
  int totalSakit = 0;
  int totalIzin = 0;
  int totalAlpha = 0;  

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }
 

  Future<void> _loadAttendanceData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      // Token tidak ada, navigasikan ke halaman login
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    try {
      var response = await myHttp.get(
        Uri.parse('https://absensidb.naar.my.id/api/presensi'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceData = json.decode(response.body)['data'] ?? [];
          _calculateTotals();
        });
      } else {
        // Gagal mengambil data, tampilkan pesan atau arahkan ke login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data, silakan coba lagi.')),
        );
      }
    } catch (e) {
      print('Exception terjadi: $e');
    }
  }

  void _calculateTotals() {
    totalHadir = _attendanceData!
        .where((item) =>
            item['keterangan'] == 'hadir' || item['keterangan'] == 'telat')
        .length;
    totalSakit =
        _attendanceData!.where((item) => item['keterangan'] == 'sakit').length;
    totalIzin =
        _attendanceData!.where((item) => item['keterangan'] == 'izin').length;
    totalAlpha =
        _attendanceData!.where((item) => item['keterangan'] == 'alpha').length;
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,  // Sesuaikan agar Text sejajar ke kiri
      children: [
        // AppBar Custom dengan sudut melengkung
        Container(
          height: 85.0,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(19.0),
              bottomRight: Radius.circular(19.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 28.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presensi SMK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  onPressed: () {
                    _logout();
                  },
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),  // Sesuaikan padding jika perlu
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian grid dashboard
              Row(
                children: [
                  Expanded(
                    child: buildDashboardItem(
                      icon: Icons.person,
                      title: 'Total Hadir',
                      count: totalHadir,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: buildDashboardItem(
                      icon: Icons.local_hospital,
                      title: 'Total Sakit',
                      count: totalSakit,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: buildDashboardItem(
                      icon: Icons.mail,
                      title: 'Total Izin',
                      count: totalIzin,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: buildDashboardItem(
                      icon: Icons.scatter_plot,
                      title: 'Total Alpha',
                      count: totalAlpha,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0), // Sesuaikan ukuran height untuk jarak yang lebih kecil
              Text(
                'Halaman Absen',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          // Bungkus ListView dengan Expanded
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),  // Padding kanan-kiri pada Expanded ListView
            child: _attendanceData == null
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _attendanceData!.length,
                    itemBuilder: (context, index) {
                      final attendance = _attendanceData![index];
                      return buildAttendanceItem(attendance);
                    },
                  ),)
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        // Aksi ketika tombol ditekan, misalnya pindah ke halaman presensi
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Simpanpresensi()))
            .then((value) {
          setState(() {
            // Lakukan update jika dibutuhkan
            _loadAttendanceData();  // Panggil ulang data jika perlu
          });
        });
      },
      child: Icon(Icons.add),  // Ikon tombol
      backgroundColor: Colors.blue,  // Warna tombol
    ),
  );
}

  Widget buildDashboardItem({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
  padding: const EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    children: [
      Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          icon,
          size: 32.0,
          color: color,
        ),
      ),
      SizedBox(width: 16.0),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ],
  ),
);

  }

  Widget buildAttendanceItem(dynamic attendance) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.person,
              size: 32.0,
              color: Colors.teal,
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance['siswa'] != null
                      ? attendance['siswa']['nama']
                      : 'Nama Siswa',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow
                      .ellipsis, 
                  maxLines: 1,
                ),
                SizedBox(height: 4.0),
                Text(
                  attendance['tanggal'] ?? 'Tanggal',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              attendance['keterangan'] ?? 'Hadir',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      var response = await myHttp.post(
        Uri.parse('https://absensidb.naar.my.id/api/auth/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout gagal, coba lagi.'),
          ),
        );
      }
    }
  }
}
