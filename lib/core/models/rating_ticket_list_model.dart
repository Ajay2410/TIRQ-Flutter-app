// To parse this JSON data, do
//
//     final ticketModel = ticketModelFromJson(jsonString);

import 'dart:convert';

RatingTicketListModel ticketModelFromJson(String str) => RatingTicketListModel.fromJson(json.decode(str));

String ticketModelToJson(RatingTicketListModel data) => json.encode(data.toJson());

class RatingTicketListModel {
  int? total;
  int? page;
  int? pages;
  int? count;
  List<RatingList>? data;

  RatingTicketListModel({this.total, this.page, this.pages, this.count, this.data});

  factory RatingTicketListModel.fromJson(Map<String, dynamic> json) => RatingTicketListModel(
    total: json["total"] ?? 1,
    page: json["page"] ?? 1,
    pages: json["pages"] ?? 1,
    count: json["count"] ?? 20,
    data: json["data"] == null ? [] : List<RatingList>.from(json["data"]!.map((x) => RatingList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "pages": pages,
    "count": count,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class RatingList {
  String? sId;
  String? ticketNumber;
  String? problem;
  String? errorCode;
  String? notes;
  List<Media>? media;
  String? ticketType;
  String? type;
  String? status;
  bool? isActive;
  Machine? machine;
  Processor? processor;
  Organisation? organisation;
  String? pricing;
  String? paymentStatus;
  bool? isShowChatOption;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? reportDescription;
  String? reportTitle;
  String? feedback;
  String? rating;

  RatingList(
      {this.sId,
        this.ticketNumber,
        this.problem,
        this.errorCode,
        this.notes,
        this.media,
        this.ticketType,
        this.type,
        this.status,
        this.isActive,
        this.machine,
        this.processor,
        this.organisation,
        this.pricing,
        this.paymentStatus,
        this.isShowChatOption,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.reportDescription,
        this.reportTitle,
        this.feedback,
        this.rating});

  RatingList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    ticketNumber = json['ticketNumber'];
    problem = json['problem'];
    errorCode = json['errorCode'];
    notes = json['notes'];
    media = json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x)));
    ticketType = json['ticketType'];
    type = json['type'];
    status = json['status'];
    isActive = json['isActive'];
    machine =
    json['machine'] != null ? new Machine.fromJson(json['machine']) : null;
    processor = json['processor'] != null
        ? new Processor.fromJson(json['processor'])
        : null;
    organisation = json['organisation'] != null
        ? new Organisation.fromJson(json['organisation'])
        : null;
    pricing = json['pricing'];
    paymentStatus = json['paymentStatus'];
    isShowChatOption = json['IsShowChatOption'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    reportDescription = json['reportDescription'];
    reportTitle = json['reportTitle'];
    feedback = json['feedback'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['ticketNumber'] = ticketNumber;
    data['problem'] = problem;
    data['errorCode'] = errorCode;
    data['notes'] = notes;
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    data['ticketType'] = ticketType;
    data['type'] = type;
    data['status'] = status;
    data['isActive'] = isActive;
    if (machine != null) {
      data['machine'] = machine!.toJson();
    }
    if (processor != null) {
      data['processor'] = processor!.toJson();
    }
    if (organisation != null) {
      data['organisation'] = organisation!.toJson();
    }
    data['pricing'] = pricing;
    data['paymentStatus'] = paymentStatus;
    data['IsShowChatOption'] = isShowChatOption;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['reportDescription'] = reportDescription;
    data['reportTitle'] = reportTitle;
    data['feedback'] = feedback;
    data['rating'] = rating;
    return data;
  }
}

class Media {
  String? url;
  String? type;
  String? id;

  Media({this.url, this.type, this.id});

  factory Media.fromJson(Map<String, dynamic> json) => Media(url: json["url"], type: json["type"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"url": url, "type": type, "_id": id};
}

class Machine {
  ProcessingDimensions? processingDimensions;
  String? sId;
  String? machineName;
  String? modelNumber;
  String? machineType;
  String? user;
  int? totalPower;
  String? manualsLink;
  String? notes;
  String? status;
  bool? isActive;
  String? remarks;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Machine(
      {this.processingDimensions,
        this.sId,
        this.machineName,
        this.modelNumber,
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
        this.iV});

  Machine.fromJson(Map<String, dynamic> json) {
    processingDimensions = json['processingDimensions'] != null
        ? new ProcessingDimensions.fromJson(json['processingDimensions'])
        : null;
    sId = json['_id'];
    machineName = json['machineName'];
    modelNumber = json['modelNumber'];
    machineType = json['machine_type'];
    user = json['user'];
    totalPower = json['totalPower'];
    manualsLink = json['manualsLink'];
    notes = json['notes'];
    status = json['status'];
    isActive = json['isActive'];
    remarks = json['remarks'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (processingDimensions != null) {
      data['processingDimensions'] = processingDimensions!.toJson();
    }
    data['_id'] = sId;
    data['machineName'] = machineName;
    data['modelNumber'] = modelNumber;
    data['machine_type'] = machineType;
    data['user'] = user;
    data['totalPower'] = totalPower;
    data['manualsLink'] = manualsLink;
    data['notes'] = notes;
    data['status'] = status;
    data['isActive'] = isActive;
    data['remarks'] = remarks;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class ProcessingDimensions {
  int? maxHeight;
  int? maxWidth;
  int? minHeight;
  int? minWidth;
  String? thickness;
  int? maxSpeed;

  ProcessingDimensions(
      {this.maxHeight,
        this.maxWidth,
        this.minHeight,
        this.minWidth,
        this.thickness,
        this.maxSpeed});

  ProcessingDimensions.fromJson(Map<String, dynamic> json) {
    maxHeight = json['maxHeight'];
    maxWidth = json['maxWidth'];
    minHeight = json['minHeight'];
    minWidth = json['minWidth'];
    thickness = json['thickness'];
    maxSpeed = json['maxSpeed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maxHeight'] = maxHeight;
    data['maxWidth'] = maxWidth;
    data['minHeight'] = minHeight;
    data['minWidth'] = minWidth;
    data['thickness'] = thickness;
    data['maxSpeed'] = maxSpeed;
    return data;
  }
}

class Processor {
  dynamic resetPasswordOTP;
  dynamic resetPasswordExpires;
  bool? isOtpVerifiedForReset;
  String? sId;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? countryCode;
  List<String>? roles;
  String? emailOTP;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  int? iV;
  String? fcmToken;

  Processor(
      {this.resetPasswordOTP,
        this.resetPasswordExpires,
        this.isOtpVerifiedForReset,
        this.sId,
        this.fullName,
        this.email,
        this.password,
        this.phone,
        this.countryCode,
        this.roles,
        this.emailOTP,
        this.isEmailVerified,
        this.isPhoneVerified,
        this.iV,
        this.fcmToken});

  Processor.fromJson(Map<String, dynamic> json) {
    resetPasswordOTP = json['resetPasswordOTP'];
    resetPasswordExpires = json['resetPasswordExpires'];
    isOtpVerifiedForReset = json['isOtpVerifiedForReset'];
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    countryCode = json['countryCode'];
    roles = json['roles'].cast<String>();
    emailOTP = json['emailOTP'];
    isEmailVerified = json['isEmailVerified'];
    isPhoneVerified = json['isPhoneVerified'];
    iV = json['__v'];
    fcmToken = json['fcmToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resetPasswordOTP'] = resetPasswordOTP;
    data['resetPasswordExpires'] = resetPasswordExpires;
    data['isOtpVerifiedForReset'] = isOtpVerifiedForReset;
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phone;
    data['countryCode'] = countryCode;
    data['roles'] = roles;
    data['emailOTP'] = emailOTP;
    data['isEmailVerified'] = isEmailVerified;
    data['isPhoneVerified'] = isPhoneVerified;
    data['__v'] = iV;
    data['fcmToken'] = fcmToken;
    return data;
  }
}

class Organisation {
  dynamic resetPasswordOTP;
  dynamic resetPasswordExpires;
  bool? isOtpVerifiedForReset;
  String? sId;
  String? fullName;
  String? email;
  String? password;
  String? phone;
  String? countryCode;
  List<String>? roles;
  String? emailOTP;
  bool? isEmailVerified;
  bool? isPhoneVerified;
  int? iV;

  Organisation(
      {this.resetPasswordOTP,
        this.resetPasswordExpires,
        this.isOtpVerifiedForReset,
        this.sId,
        this.fullName,
        this.email,
        this.password,
        this.phone,
        this.countryCode,
        this.roles,
        this.emailOTP,
        this.isEmailVerified,
        this.isPhoneVerified,
        this.iV});

  Organisation.fromJson(Map<String, dynamic> json) {
    resetPasswordOTP = json['resetPasswordOTP'];
    resetPasswordExpires = json['resetPasswordExpires'];
    isOtpVerifiedForReset = json['isOtpVerifiedForReset'];
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    countryCode = json['countryCode'];
    roles = json['roles'].cast<String>();
    emailOTP = json['emailOTP'];
    isEmailVerified = json['isEmailVerified'];
    isPhoneVerified = json['isPhoneVerified'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resetPasswordOTP'] = resetPasswordOTP;
    data['resetPasswordExpires'] = resetPasswordExpires;
    data['isOtpVerifiedForReset'] = isOtpVerifiedForReset;
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['password'] = password;
    data['phone'] = phone;
    data['countryCode'] = countryCode;
    data['roles'] = roles;
    data['emailOTP'] = emailOTP;
    data['isEmailVerified'] = isEmailVerified;
    data['isPhoneVerified'] = isPhoneVerified;
    data['__v'] = iV;
    return data;
  }
}

