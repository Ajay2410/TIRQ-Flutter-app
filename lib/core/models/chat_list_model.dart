// To parse this JSON data, do
//
//     final chatListModel = chatListModelFromJson(jsonString);

import 'dart:convert';

List<ChatListModel> chatListModelFromJson(String str) => List<ChatListModel>.from(json.decode(str).map((x) => ChatListModel.fromJson(x)));

String chatListModelToJson(List<ChatListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatListModel {
  String? id;
  Ticket? ticket;
  ChatWith? chatWith;

  ChatListModel({
    this.id,
    this.ticket,
    this.chatWith,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
    id: json["_id"],
    ticket: json["ticket"] == null ? null : Ticket.fromJson(json["ticket"]),
    chatWith: json["chatWith"] == null ? null : ChatWith.fromJson(json["chatWith"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticket": ticket?.toJson(),
    "chatWith": chatWith?.toJson(),
  };
}

class ChatWith {
  String? id;
  String? fullName;
  String? email;

  ChatWith({
    this.id,
    this.fullName,
    this.email,
  });

  factory ChatWith.fromJson(Map<String, dynamic> json) => ChatWith(
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "email": email,
  };
}

class Ticket {
  String? id;
  String? ticketNumber;
  String? problem;
  String? errorCode;
  String? notes;
  List<Media>? media;
  String? ticketType;
  String? type;
  String? status;
  bool? isActive;
  String? machine;
  String? processor;
  String? organisation;
  String? pricing;
  String? paymentStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Ticket({
    this.id,
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
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json["_id"],
    ticketNumber: json["ticketNumber"],
    problem: json["problem"],
    errorCode: json["errorCode"],
    notes: json["notes"],
    media: json["media"] == null ? [] : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
    ticketType: json["ticketType"],
    type: json["type"],
    status: json["status"],
    isActive: json["isActive"],
    machine: json["machine"],
    processor: json["processor"],
    organisation: json["organisation"],
    pricing: json["pricing"],
    paymentStatus: json["paymentStatus"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketNumber": ticketNumber,
    "problem": problem,
    "errorCode": errorCode,
    "notes": notes,
    "media": media == null ? [] : List<dynamic>.from(media!.map((x) => x.toJson())),
    "ticketType": ticketType,
    "type": type,
    "status": status,
    "isActive": isActive,
    "machine": machine,
    "processor": processor,
    "organisation": organisation,
    "pricing": pricing,
    "paymentStatus": paymentStatus,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Media {
  String? url;
  String? type;
  String? id;

  Media({
    this.url,
    this.type,
    this.id,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    url: json["url"],
    type: json["type"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "type": type,
    "_id": id,
  };
}
