// leave_request_provider.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/leave_request.dart';

class LeaveRequestProvider with ChangeNotifier {
  List<LeaveRequest> _leaveRequests = [];

  List<LeaveRequest> get leaveRequests => _leaveRequests;

  Future<void> fetchLeaveRequests(String token) async {
    print('Token yang digunakan: $token'); 
    final url = 'http://192.168.188.216:8000/api/leave-requests';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      _leaveRequests = data.map((item) => LeaveRequest.fromJson(item)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load leave requests');
    }
  }

  Future<void> submitLeaveRequest(
      String token, String leaveType, String startDate, String endDate, String reason) async {
    final url = 'http://192.168.188.216:8000/api/leave-request';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'leave_type': leaveType,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      }),
    );

   print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      fetchLeaveRequests(token);
    } else {
      throw Exception('Failed to submit leave request');
    }
  }
}
