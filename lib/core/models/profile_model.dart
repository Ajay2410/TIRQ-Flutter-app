// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  String? id;
  User? user;
  String? unitName;
  String? designation;
  String? organizationName;
  Address? corporateAddress;
  Address? factoryAddress;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ProfileModel({
    this.id,
    this.user,
    this.unitName,
    this.designation,
    this.organizationName,
    this.corporateAddress,
    this.factoryAddress,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    unitName: json["unitName"],
    designation: json["designation"],
    organizationName: json["organizationName"],
    corporateAddress: json["corporateAddress"] == null ? null : Address.fromJson(json["corporateAddress"]),
    factoryAddress: json["factoryAddress"] == null ? null : Address.fromJson(json["factoryAddress"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user?.toJson(),
    "unitName": unitName,
    "designation": designation,
    "organizationName": organizationName,
    "corporateAddress": corporateAddress?.toJson(),
    "factoryAddress": factoryAddress?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Address {
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? id;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.id,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    pincode: json["pincode"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "pincode": pincode,
    "_id": id,
  };
}

class User {
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
  dynamic resetPasswordOtp;
  dynamic resetPasswordExpires;
  bool? isOtpVerifiedForReset;
  int? v;

  User({
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
    this.resetPasswordOtp,
    this.resetPasswordExpires,
    this.isOtpVerifiedForReset,
    this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    countryCode: json["countryCode"],
    roles: json["roles"] == null ? [] : List<String>.from(json["roles"]!.map((x) => x)),
    emailOtp: json["emailOTP"],
    isEmailVerified: json["isEmailVerified"],
    isPhoneVerified: json["isPhoneVerified"],
    resetPasswordOtp: json["resetPasswordOTP"],
    resetPasswordExpires: json["resetPasswordExpires"],
    isOtpVerifiedForReset: json["isOtpVerifiedForReset"],
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
    "resetPasswordOTP": resetPasswordOtp,
    "resetPasswordExpires": resetPasswordExpires,
    "isOtpVerifiedForReset": isOtpVerifiedForReset,
    "__v": v,
  };
}
