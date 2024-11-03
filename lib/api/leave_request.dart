// leave_request.dart

import 'dart:convert';

LeaveRequest leaveRequestFromJson(String str) =>
    LeaveRequest.fromJson(json.decode(str));

String leaveRequestToJson(LeaveRequest data) => json.encode(data.toJson());

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });

  int id;
  String leaveType;
  String startDate;
  String endDate;
  String reason;
  String status;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json["id"],
        leaveType: json["leave_type"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        reason: json["reason"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "leave_type": leaveType,
        "start_date": startDate,
        "end_date": endDate,
        "reason": reason,
        "status": status,
      };
}
