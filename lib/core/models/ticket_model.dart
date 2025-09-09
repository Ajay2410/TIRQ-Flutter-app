// To parse this JSON data, do
//
//     final ticketModel = ticketModelFromJson(jsonString);

import 'dart:convert';
import '../enums/ticket_status_enum.dart';
import '../enums/warranty_status_enum.dart';

List<TicketModel> ticketModelFromJson(String str) => List<TicketModel>.from(
  json.decode(str).map((x) => TicketModel.fromJson(x)),
);

String ticketModelToJson(List<TicketModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Paginated response model
class PaginatedTicketResponse {
  int total;
  int page;
  int pages;
  int count;
  List<TicketModel> data;

  PaginatedTicketResponse({
    required this.total,
    required this.page,
    required this.pages,
    required this.count,
    required this.data,
  });

  factory PaginatedTicketResponse.fromJson(Map<String, dynamic> json) =>
      PaginatedTicketResponse(
        total: json["total"] ?? 0,
        page: json["page"] ?? 1,
        pages: json["pages"] ?? 1,
        count: json["count"] ?? 0,
        data:
            json["data"] == null
                ? []
                : List<TicketModel>.from(
                  json["data"].map((x) => TicketModel.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "pages": pages,
    "count": count,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class TicketModel {
  String? id;
  String? problem;
  String? errorCode;
  String? notes;
  List<Media>? media;
  String? ticketType;
  String? status;
  bool? isActive;
  Machine? machine;
  Organisation? processor;
  Organisation? organisation;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  TicketModel({
    this.id,
    this.problem,
    this.errorCode,
    this.notes,
    this.media,
    this.ticketType,
    this.status,
    this.isActive,
    this.machine,
    this.processor,
    this.organisation,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json["_id"],
    problem: json["problem"],
    errorCode: json["errorCode"],
    notes: json["notes"],
    media:
        json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    ticketType: json["ticketType"],
    status: json["status"],
    isActive: json["isActive"],
    machine: json["machine"] == null ? null : Machine.fromJson(json["machine"]),
    processor:
        json["processor"] == null
            ? null
            : Organisation.fromJson(json["processor"]),
    organisation:
        json["organisation"] == null
            ? null
            : Organisation.fromJson(json["organisation"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "problem": problem,
    "errorCode": errorCode,
    "notes": notes,
    "media":
        media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "ticketType": ticketType,
    "status": status,
    "isActive": isActive,
    "machine": machine?.toJson(),
    "processor": processor?.toJson(),
    "organisation": organisation?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };

  // Getter for status enum
  TicketStatus? get ticketStatus => TicketStatus.fromString(status);

  // Getter for warranty status enum
  WarrantyStatus? get warrantyStatus =>
      WarrantyStatus.fromString(machine?.status);
}

class Machine {
  ProcessingDimensions? processingDimensions;
  String? id;
  String? machineName;
  String? modelNumber;
  String? serialNumber;
  String? machineType;
  String? user;
  int? totalPower;
  String? manualsLink;
  String? notes;
  String? status;
  bool? isActive;
  String? remarks;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Machine({
    this.processingDimensions,
    this.id,
    this.machineName,
    this.modelNumber,
    this.serialNumber,
    this.machineType,
    this.user,
    this.totalPower,
    this.manualsLink,
    this.notes,
    this.status,
    this.isActive,
    this.remarks,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
    processingDimensions:
        json["processingDimensions"] == null
            ? null
            : ProcessingDimensions.fromJson(json["processingDimensions"]),
    id: json["_id"],
    machineName: json["machineName"],
    modelNumber: json["modelNumber"],
    serialNumber: json["serialNumber"],
    machineType: json["machine_type"],
    user: json["user"],
    totalPower: json["totalPower"],
    manualsLink: json["manualsLink"],
    notes: json["notes"],
    status: json["status"],
    isActive: json["isActive"],
    remarks: json["remarks"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "processingDimensions": processingDimensions?.toJson(),
    "_id": id,
    "machineName": machineName,
    "modelNumber": modelNumber,
    "serialNumber": serialNumber,
    "machine_type": machineType,
    "user": user,
    "totalPower": totalPower,
    "manualsLink": manualsLink,
    "notes": notes,
    "status": status,
    "isActive": isActive,
    "remarks": remarks,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ProcessingDimensions {
  int? maxHeight;
  int? maxWidth;
  int? minHeight;
  int? minWidth;
  String? thickness;
  int? maxSpeed;

  ProcessingDimensions({
    this.maxHeight,
    this.maxWidth,
    this.minHeight,
    this.minWidth,
    this.thickness,
    this.maxSpeed,
  });

  factory ProcessingDimensions.fromJson(Map<String, dynamic> json) =>
      ProcessingDimensions(
        maxHeight: json["maxHeight"],
        maxWidth: json["maxWidth"],
        minHeight: json["minHeight"],
        minWidth: json["minWidth"],
        thickness: json["thickness"],
        maxSpeed: json["maxSpeed"],
      );

  Map<String, dynamic> toJson() => {
    "maxHeight": maxHeight,
    "maxWidth": maxWidth,
    "minHeight": minHeight,
    "minWidth": minWidth,
    "thickness": thickness,
    "maxSpeed": maxSpeed,
  };
}

class Media {
  String? url;
  String? type;
  String? id;

  Media({this.url, this.type, this.id});

  factory Media.fromJson(Map<String, dynamic> json) =>
      Media(url: json["url"], type: json["type"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"url": url, "type": type, "_id": id};
}

class Organisation {
  String? id;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? countryCode;
  List<String>? roles;
  String? emailOtp;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  int? v;

  Organisation({
    this.id,
    this.fullName,
    this.email,
    this.password,
    this.phone,
    this.countryCode,
    this.roles,
    this.emailOtp,
    this.isEmailVerified,
    this.isPhoneVerified,
    this.v,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) => Organisation(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    roles:
        json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
    emailOtp: json["emailOTP"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
    "password": password,
    "phone": phone,
    "countryCode": countryCode,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x)),
    "emailOTP": emailOtp,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "__v": v,
  };
}
