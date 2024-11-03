// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'api/home-response.dart';
// import 'models/simpan-page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as myHttp;

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//   late String _name, _token;
//   HomeResponseModel? homeResponseModel;
//   Datum? hariIni;
//   List<Datum> riwayatPresensi = [];
//   List<dynamic> leaveRequests = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     initializeData();
//   }

//   Future<void> initializeData() async {
//     SharedPreferences prefs = await _prefs;
//     _token = prefs.getString("token") ?? "";
//     _name = prefs.getString("name") ?? "";

//     await getDataPresensi();

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> getDataPresensi() async {
//     try {
//       final Map<String, String> headers = {'Authorization': 'Bearer ' + _token};
//       var response = await myHttp.get(
//           Uri.parse('http://192.168.20.25:8000/api/presensi'),
//           headers: headers);
//       print(response.body);
//       if (response.statusCode == 200) {
//         homeResponseModel =
//             HomeResponseModel.fromJson(json.decode(response.body));

//         riwayatPresensi.clear();
//         homeResponseModel!.data.forEach((element) {
//           if (element.isHariIni) {
//             hariIni = element;
//           } else {
//             riwayatPresensi.add(element);
//           }
//         });
//       } else {
//         print('Error: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching presensi data: $e');
//     }
//   }

//   String formatDate(String dateStr) {
//     DateTime parsedDate = DateTime.parse(dateStr);
//     return DateFormat('dd MMMM yyyy', 'id_ID').format(parsedDate);
//   }

  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Beranda'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SafeArea(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   // Cek jika lebar layar lebih besar dari 600px (tablet)
//                   bool isTablet = constraints.maxWidth > 600;

//                   return Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(_name, style: TextStyle(fontSize: 18)),
//                         SizedBox(height: 20),
//                         Container(
//                           width: isTablet ? 600 : double.infinity, // Responsif
//                           decoration: BoxDecoration(color: Colors.blue[800]),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(children: [
//                               Text(hariIni?.tanggal ?? '-',
//                                   style: TextStyle(
//                                       color: Colors.white, fontSize: 16)),
//                               SizedBox(height: 30),
//                             ]),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Text("Riwayat Presensi",
//                             style: TextStyle(fontSize: 18)),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: riwayatPresensi.length,
//                             itemBuilder: (context, index) => Card(
//                               child: ListTile(
//                                 leading: Text(
//                                     formatDate(riwayatPresensi[index].tanggal)),
//                                 title: Row(
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Text(riwayatPresensi[index].masuk,
//                                             style: TextStyle(fontSize: 18)),
//                                         Text("Masuk",
//                                             style: TextStyle(fontSize: 14))
//                                       ],
//                                     ),
//                                     SizedBox(width: 20),
//                                     Column(
//                                       children: [
//                                         Text(
//                                             riwayatPresensi[index].pulang ??
//                                                 '-',
//                                             style: TextStyle(fontSize: 18)),
//                                         Text("Pulang",
//                                             style: TextStyle(fontSize: 14))
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       Navigator.of(context)
    //           .push(MaterialPageRoute(builder: (context) => Simpanpresensi()))
    //           .then((value) {
    //         setState(() {
    //           isLoading = true;
    //           initializeData();
    //         });
    //       });
    //     },
    //     child: Icon(Icons.add),
    //   ),
    // );
//   }
// }
