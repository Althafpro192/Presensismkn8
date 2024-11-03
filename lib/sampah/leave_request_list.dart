// leave_request_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'leave_request_provider.dart';

class LeaveRequestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leaveProvider = Provider.of<LeaveRequestProvider>(context);
    final token = 'YOUR_TOKEN_HERE'; // Ganti dengan token dari login atau shared preferences

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Izin'),
      ),
      body: FutureBuilder(
        future: leaveProvider.fetchLeaveRequests(token),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: leaveProvider.leaveRequests.length,
              itemBuilder: (ctx, i) {
                return ListTile(
                  title: Text(leaveProvider.leaveRequests[i].leaveType),
                  subtitle: Text(
                    'Mulai: ${leaveProvider.leaveRequests[i].startDate} - Akhir: ${leaveProvider.leaveRequests[i].endDate}',
                  ),
                  trailing: Text(leaveProvider.leaveRequests[i].status),
                );
              },
            );
          }
        },
      ),
    );
  }
}
