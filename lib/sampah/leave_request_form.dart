import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart'; // Import untuk format tanggal
import 'package:shared_preferences/shared_preferences.dart';

import 'leave_request_provider.dart'; // Untuk mengambil token

class LeaveRequestForm extends StatefulWidget {
  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = '';
  String _reason = '';
  
  // Untuk tanggal
  DateTime? _startDate;
  DateTime? _endDate;
  String? _token;

  @override
  void initState() {
    super.initState();
    _getToken(); // Mengambil token saat widget diinisialisasi
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveProvider = Provider.of<LeaveRequestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajukan Izin'),
      ),
      body: _token == null
          ? Center(child: CircularProgressIndicator()) // Jika token belum ada, tampilkan loading
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Jenis Izin'),
                      onSaved: (value) {
                        _leaveType = value!;
                      },
                    ),
                    
                    // Date picker untuk Tanggal Mulai
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startDate == null
                            ? 'Pilih Tanggal Mulai'
                            : 'Mulai: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, isStartDate: true),
                          child: Text('Pilih Tanggal Mulai'),
                        ),
                      ],
                    ),
                    
                    // Date picker untuk Tanggal Akhir
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_endDate == null
                            ? 'Pilih Tanggal Akhir'
                            : 'Akhir: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                        ElevatedButton(
                          onPressed: () => _selectDate(context, isStartDate: false),
                          child: Text('Pilih Tanggal Akhir'),
                        ),
                      ],
                    ),
                    
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Alasan Izin'),
                      onSaved: (value) {
                        _reason = value!;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (_startDate != null && _endDate != null) {
                            leaveProvider.submitLeaveRequest(
                              _token!,
                              _leaveType,
                              DateFormat('yyyy-MM-dd').format(_startDate!),
                              DateFormat('yyyy-MM-dd').format(_endDate!),
                              _reason,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Izin berhasil diajukan!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Pilih tanggal mulai dan akhir!')),
                            );
                          }
                        }
                      },
                      child: Text('Ajukan Izin'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }
}
