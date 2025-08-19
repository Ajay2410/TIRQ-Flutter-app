import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:manager/core/models/ticket.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import 'chat.vm.dart';

class ChatViewAttributes {
  final String id;
  final Ticket? ticket;
  final String status;
  final String? groupName;
  final String? chatRoomType;
  final User? organization;
  final List<ChatParticipant> participants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatViewAttributes({
    required this.id,
    this.ticket,
    this.groupName,
    this.chatRoomType,
    this.organization,
    required this.status,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatViewAttributes.fromJson(Map<String, dynamic> json) {
    return ChatViewAttributes(
      id: json['chatRoomId'] ?? '',
      ticket: json['chatRoomData']['ticketId'] != null
          ? Ticket.fromJson(json['chatRoomData']?['ticketId'])
          : null,
      groupName: json['chatRoomData']?['groupName'] ?? LanguageService.get("chat"),
      chatRoomType: json['chatRoomData']?['chatRoomType'],
      status: json['chatRoomData']?['status'] ?? '',
      organization: json['chatRoomData']?['organization'] != null
          ? User.fromJson(json['chatRoomData']?['organization'])
          : null,
      participants: (json['chatRoomData']?['participants'] as List?)
          ?.map((employee) => ChatParticipant.fromJson(employee))
          .toList() ??
          [],
      createdAt: DateTime.tryParse(json['chatRoomData']?['createdAt'] ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['chatRoomData']?['updatedAt'] ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': id,
      'chatRoomData': {
        'ticketId': ticket?.toJson(),
        'groupName': groupName,
        'chatRoomType': chatRoomType,
        'status': status,
        'organization': organization?.toJson(),
        'participants': participants.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profilePhoto;

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePhoto,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
    };
  }
}

class ChatView extends StatefulWidget {
  final ChatViewAttributes attributes;

  const ChatView({super.key, required this.attributes});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    _startPingTimer();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    super.dispose();
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      onViewModelReady: (viewModel) => viewModel.init(widget.attributes),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context, model),
        body: Column(
          children: [
            if (model.ticket != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTicketDetails(context, model),
              ),
            Divider(height: 1, thickness: 1, color: AppColors.lightGray),
            Expanded(
              flex: 3,
              child: _buildChatMessages(context, model),
            ),
            if (model.chatAttributes.status != 'archived')
              _buildMessageInput(context, model),
          ],
        ),
      ),
    );
  }

  bool canPing(Ticket ticket) {
    if (ticket.lastPingTime == null) return true;
    try {
      final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
      final now = DateTime.now();
      if (lastPingDateTime.isAfter(now)) return false;
      final difference = now.difference(lastPingDateTime);
      return difference.inMinutes >= 5;
    } catch (e) {
      return true;
    }
  }

  String remainingPingTime(Ticket ticket) {
    if (ticket.lastPingTime == null) return '0:00';
    try {
      final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
      final now = DateTime.now();
      DateTime nextPingTime = lastPingDateTime.add(Duration(minutes: 5));
      if (lastPingDateTime.isAfter(now)) nextPingTime = lastPingDateTime;
      if (now.isAfter(nextPingTime)) return '0:00';
      final remaining = nextPingTime.difference(now);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes;
      final seconds = remaining.inSeconds % 60;
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }

  Widget _buildTicketDetails(BuildContext context, ChatViewModel model) {
    final ticket = model.ticket!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final createdDate = ticket.createdAt != null
        ? dateFormat.format(DateTime.parse(ticket.createdAt!))
        : LanguageService.get("not_available");

    String getTimeAgo(DateTime dateTime) {
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays} ${difference.inDays == 1 ? LanguageService.get("day") : LanguageService.get("days")}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${difference.inHours == 1 ? LanguageService.get("hour") : LanguageService.get("hours")}';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? LanguageService.get("minute") : LanguageService.get("minutes")}';
      } else {
        return LanguageService.get("just_now");
      }
    }

    final updatedDate = ticket.updatedAt != null
        ? getTimeAgo(DateTime.parse(ticket.updatedAt!))
        : LanguageService.get("not_available");

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        iconColor: AppColors.black,
        trailing: Icon(Icons.keyboard_arrow_down_sharp, color: AppColors.black),
        title: Row(
          children: [
            Icon(Icons.confirmation_number, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${LanguageService.get("id")}: ${ticket.ticketId ?? ticket.id.substring(0, 8)}',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(ticket.status ?? LanguageService.get("open")),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatStatus(ticket.status ?? LanguageService.get("open")),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: LanguageService.get("ticket_type"),
                        value: ticket.ticketType ?? LanguageService.get("not_specified"),
                        icon: Icons.category_outlined,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        label: LanguageService.get("pending_since"),
                        value: updatedDate,
                        icon: Icons.update_outlined,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                if (ticket.machine != null)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          label: LanguageService.get("machine"),
                          value: ticket.machine?.machineName ?? LanguageService.get("not_specified"),
                          icon: Icons.precision_manufacturing_outlined,
                        ),
                      ),
                      if (ticket.machine?.serialNumber != null)
                        Expanded(
                          child: _buildInfoRow(
                            label: LanguageService.get("model_number"),
                            value: ticket.machine!.serialNumber!,
                            icon: Icons.confirmation_number_outlined,
                          ),
                        ),
                    ],
                  ),
                if (getUser().organizationType == OrganizationType.processor) ...[
                  _buildInfoRow(
                    label: LanguageService.get("manufacturer"),
                    value: getUser().organizationType == OrganizationType.processor
                        ? "${ticket.manufacturerInfo?.name ?? LanguageService.get("not_specified")}"
                        ' (${ticket.manufacturerInfo?.email ?? LanguageService.get("not_specified")})'
                        : ticket.manufacturerInfo?.name ?? LanguageService.get("not_specified"),
                    icon: Icons.business_outlined,
                  ),
                ],
                if (getUser().organizationType == OrganizationType.manufacturer) ...[
                  _buildInfoRow(
                    label: LanguageService.get("processor"),
                    value: getUser().organizationType == OrganizationType.manufacturer
                        ? "${ticket.processorInfo?.name ?? LanguageService.get("not_specified")}"
                        ' (${ticket.processorInfo?.email ?? LanguageService.get("not_specified")})'
                        : ticket.processorInfo?.name ?? LanguageService.get("not_specified"),
                    icon: Icons.person_outlined,
                  ),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        label: LanguageService.get("created"),
                        value: createdDate,
                        icon: Icons.date_range_outlined,
                      ),
                    ),
                  ],
                ),
                if (ticket.machine?.warranty != null)
                  _buildInfoRow(
                    label: LanguageService.get("warranty_status"),
                    value: _getWarrantyStatus(ticket),
                    icon: Icons.timer_outlined,
                  ),
                _buildInfoRow(
                  label: LanguageService.get("description"),
                  value: ticket.description ?? LanguageService.get("not_specified"),
                  icon: Icons.description_outlined,
                  isMultiline: true,
                ),
                ...List.generate(ticket.additionalInfo?.length ?? 0, (index) {
                  return _buildInfoRow(
                    label: ticket.additionalInfo![index].title!,
                    value: ticket.additionalInfo![index].description!,
                    icon: Icons.error_outline,
                    isMultiline: true,
                  );
                }),
                if (ticket.attachments != null && ticket.attachments!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    '${LanguageService.get("attachments")} (${ticket.attachments!.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ticket.attachments!.length,
                      separatorBuilder: (context, index) => SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => model.navigateToImageView(ticket.attachments![index]),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                ticket.attachments![index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWarrantyStatus(Ticket ticket) {
    DateTime? startDate;
    DateTime? endDate;
    if (ticket.machine?.warranty != null) {
      startDate = DateTime.parse(
        ticket.machine?.warranty?.startDate ?? DateTime.now().toUtc().toIso8601String(),
      );
      endDate = DateTime.parse(
        ticket.machine?.warranty?.expirationDate ?? DateTime.now().toUtc().toIso8601String(),
      );
    }
    String status = 'N/A';
    if (startDate != null && endDate != null) {
      if (DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate)) {
        status = 'active';
      }
      if (endDate.isBefore(DateTime.now())) {
        status = 'expired';
      }
    }
    switch (status.toLowerCase()) {
      case 'active':
        return LanguageService.get("in_warranty");
      case 'n/a':
        return LanguageService.get("not_started");
      case 'expired':
        return LanguageService.get("out_of_warranty");
      default:
        return LanguageService.get("not_started");
    }
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 14),
                  maxLines: isMultiline ? 5 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    if (status == 'InProgress') return LanguageService.get("in_progress");
    if (status == 'OnHold') return LanguageService.get("waiting");
    if (status == 'Resolved') return LanguageService.get("closed");
    if (status == 'Pending') return LanguageService.get("pending_remark");
    return status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
      case 'inprogress':
        return AppColors.primary;
      case 'pending':
        return Colors.green;
      case 'onhold':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatViewModel model) {
    String title = widget.attributes.ticket?.title ?? LanguageService.get("chat");

    return AppBar(
      elevation: 1,
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        if (model.chatAttributes.status != 'archived')
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.white),
            onPressed: () => _showChatDetailsBottomSheet(context, model),
          ),
      ],
    );
  }

  void _showChatDetailsBottomSheet(BuildContext context, ChatViewModel model) async {
    final ticket = model.ticket ?? Ticket(id: 'id');
    bool showDirectResolveButton = (ticket.resolveRequest != null && ticket.resolveRequest! >= 3);
    bool canRequestClose = showDirectResolveButton ? true : true;
    String remainingTime = '';
    bool isRescheduleExpanded = false;

    if (!showDirectResolveButton && ticket.lastPingTime != null) {
      try {
        final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
        final now = DateTime.now();
        if (lastPingDateTime.isAfter(now)) {
          canRequestClose = false;
          remainingTime = '00:00:30';
        } else {
          final oneHourAfterPing = lastPingDateTime.add(Duration(seconds: 30));
          canRequestClose = now.isAfter(oneHourAfterPing);
          if (!canRequestClose) {
            final remaining = oneHourAfterPing.difference(now);
            final hours = remaining.inHours;
            final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
            final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
            remainingTime = '$hours:$minutes:$seconds';
          }
        }
      } catch (e) {
        canRequestClose = true;
        remainingTime = '0:00:00';
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!showDirectResolveButton && !canRequestClose) {
              Timer.periodic(Duration(seconds: 1), (timer) {
                if (!context.mounted) {
                  timer.cancel();
                  return;
                }
                try {
                  final lastPingDateTime = DateTime.parse(ticket.lastPingTime!);
                  final now = DateTime.now();
                  final oneHourAfterPing = lastPingDateTime.add(Duration(seconds: 30));
                  if (now.isAfter(oneHourAfterPing)) {
                    setState(() {
                      canRequestClose = true;
                      remainingTime = '0:00:00';
                    });
                    timer.cancel();
                  } else {
                    final remaining = oneHourAfterPing.difference(now);
                    final hours = remaining.inHours;
                    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
                    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
                    setState(() {
                      remainingTime = '$hours:$minutes:$seconds';
                    });
                  }
                } catch (e) {
                  timer.cancel();
                }
              });
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.v20),
                  topRight: Radius.circular(AppSizes.v20),
                ),
              ),
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24),
                          if (getUser().organizationType == OrganizationType.manufacturer &&
                              widget.attributes.ticket != null)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSizes.v12),
                                border: Border.all(color: AppColors.primary, width: 1),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isRescheduleExpanded = !isRescheduleExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            LanguageService.get("reschedule"),
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Icon(
                                            isRescheduleExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: AppColors.primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isRescheduleExpanded) ...[
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            LanguageService.get("select_time"),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildRescheduleOption(LanguageService.get("15_mins"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("15_mins")),
                                              _buildRescheduleOption(LanguageService.get("30_mins"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("30_mins")),
                                              _buildRescheduleOption(LanguageService.get("1_hour"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("1_hour")),
                                              _buildRescheduleOption(LanguageService.get("2_hours"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("2_hours")),
                                              _buildRescheduleOption(LanguageService.get("5_hours"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("5_hours")),
                                              _buildRescheduleOption(LanguageService.get("10_hours"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("10_hours")),
                                              _buildRescheduleOption(LanguageService.get("12_hours"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("12_hours")),
                                              _buildRescheduleOption(LanguageService.get("1_day"), model,
                                                  model.selectedRescheduleOption == LanguageService.get("1_day")),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: model.selectedRescheduleOption?.isNotEmpty == true
                                                  ? () async {
                                                await model.holdTicketWithDuration(
                                                    ticket.id, model.selectedRescheduleOption!);
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                              }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                padding: EdgeInsets.symmetric(vertical: AppSizes.h12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(AppSizes.v8),
                                                ),
                                              ),
                                              child: Text(
                                                LanguageService.get("reschedule"),
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (getUser().organizationType == OrganizationType.manufacturer &&
                              model.ticket?.status == 'OnHold')
                            Container(
                              margin: EdgeInsets.only(top: AppSizes.v16),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await model.reopenTicket(model.ticket!.id);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("reopen_ticket"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          if (getUser().organizationType == OrganizationType.manufacturer &&
                              widget.attributes.ticket != null) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  model.resolveTicket(ticket.id);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("resolve_ticket"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("group_info"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("group_media"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("search"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: AppSizes.h16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.v12),
                                  ),
                                ),
                                child: Text(
                                  LanguageService.get("exit_group"),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (!showDirectResolveButton && !canRequestClose)
                              Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: AppColors.primary.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '${LanguageService.get("time_remaining")}: $remainingTime',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (showDirectResolveButton)
                              Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          LanguageService.get("multiple_resolution_requests"),
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    model.init(widget.attributes);
  }

  Widget _buildRescheduleOption(String option, ChatViewModel model, bool isSelected) {
    return GestureDetector(
      onTap: () {
        model.updateRescheduleOption(option);
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessages(BuildContext context, ChatViewModel model) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      reverse: true,
      itemCount: model.messages.length,
      itemBuilder: (context, index) {
        final message = model.messages[index];
        return _buildMessageItem(context, message, model);
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, MessageModel message, ChatViewModel model) {
    final isSentByMe = message.isSentByMe;
    final isSending = message.status == 'sending';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSentByMe) _buildAvatar(message.senderName, message.senderProfilePic),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isSentByMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                    child: Text(
                      message.senderName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isSentByMe
                        ? (isSending ? Colors.indigo[400] : Colors.indigo[600])
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildMessageContent(context, message, model),
                ),
                if (message.translatedContent != null && message.translatedContent!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              message.translatedContent!,
                              style: TextStyle(color: Colors.black87, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      SizedBox(width: 4),
                      _buildMessageStatusIcon(message, model),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSentByMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, MessageModel message, ChatViewModel model) {
    switch (message.messageType) {
      case MessageType.image:
        return GestureDetector(
          onTap: () => model.navigateToImageView(message.content),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              message.content,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  padding: EdgeInsets.all(12),
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: message.isSentByMe ? Colors.white : Colors.indigo,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: message.isSentByMe ? Colors.white : Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        LanguageService.get("failed_to_load_image"),
                        style: TextStyle(
                          color: message.isSentByMe ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
              fit: BoxFit.cover,
              width: 200,
              height: 200,
            ),
          ),
        );

      case MessageType.location:
        final coordinates = message.content.split(',');
        final lat = coordinates.length > 0 ? coordinates[0].trim() : '0';
        final lng = coordinates.length > 1 ? coordinates[1].trim() : '0';

        return GestureDetector(
          onTap: () => model.openLocation(message.content),
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: message.isSentByMe ? Colors.white : Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      LanguageService.get("location"),
                      style: TextStyle(
                        color: message.isSentByMe ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '${LanguageService.get("latitude")}: $lat',
                  style: TextStyle(
                    color: message.isSentByMe ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${LanguageService.get("longitude")}: $lng',
                  style: TextStyle(
                    color: message.isSentByMe ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 40, color: Colors.grey[600]),
                        SizedBox(height: 4),
                        Text(
                          LanguageService.get("tap_to_open_maps"),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case MessageType.link:
        return GestureDetector(
          onTap: () => model.openLink(message.content),
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: message.isSentByMe ? Colors.white : Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      LanguageService.get("link"),
                      style: TextStyle(
                        color: message.isSentByMe ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? Colors.white.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: message.isSentByMe
                          ? Colors.white.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: message.isSentByMe ? Colors.white : Colors.blue,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        LanguageService.get("tap_to_open"),
                        style: TextStyle(
                          color: message.isSentByMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case MessageType.document:
        return GestureDetector(
          onTap: () => model.openLink(message.content),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description,
                  color: message.isSentByMe ? Colors.white : Colors.grey[700],
                  size: 20,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    LanguageService.get("document"),
                    style: TextStyle(
                      color: message.isSentByMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case MessageType.text:
      default:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message.content,
            style: TextStyle(
              color: message.isSentByMe ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        );
    }
  }

  Widget _buildAvatar(String name, String profilePhoto) {
    final int colorValue = name.isEmpty
        ? 0xFF9E9E9E
        : (name.codeUnitAt(0) * 40) % 0xFFFFFF + 0xFF000000;
    final Color avatarColor = Color(colorValue);
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: 16,
      backgroundColor: avatarColor,
      backgroundImage: profilePhoto.isNotEmpty ? NetworkImage(profilePhoto) as ImageProvider : null,
      child: profilePhoto.isEmpty
          ? Text(
        firstLetter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      )
          : null,
    );
  }

  Widget _buildMessageStatusIcon(MessageModel message, ChatViewModel model) {
    if (!message.isSentByMe) return SizedBox.shrink();

    IconData icon;
    Color color;

    switch (message.status) {
      case 'sending':
        return SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
      case 'failed':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'sent':
        icon = Icons.check;
        color = Colors.grey;
        break;
      case 'delivered':
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case 'read':
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      default:
        return SizedBox.shrink();
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildMessageInput(BuildContext context, ChatViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey),
            onPressed: model.isSendingMessage ? null : () => _showAttachmentBottomSheet(context, model),
          ),
          Expanded(
            child: TextField(
              controller: model.messageController,
              enabled: !model.isSendingMessage,
              onSubmitted: (_) => model.isSendingMessage ? null : model.sendMessage(),
              decoration: InputDecoration(
                hintText: model.isSendingMessage
                    ? LanguageService.get("sending")
                    : LanguageService.get("write_message"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.grey),
                      onPressed: model.isSendingMessage ? null : () => _showCameraOptions(context, model),
                    ),
                    IconButton(
                      icon: Icon(Icons.mic, color: Colors.grey),
                      onPressed: model.isSendingMessage ? null : () => _startAudioRecording(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: model.isSendingMessage
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            )
                : Icon(Icons.send, color: Colors.indigo),
            onPressed: model.isSendingMessage
                ? null
                : model.ticket?.status == 'OnHold'
                ? () => _buildConfirmationDialog(context, model)
                : model.sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.indigo),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showAttachmentBottomSheet(BuildContext context, ChatViewModel model) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.v20),
              topRight: Radius.circular(AppSizes.v20),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageService.get("attach_file"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.image,
                    label: LanguageService.get("gallery"),
                    onTap: () {
                      Navigator.pop(context);
                      model.pickAndSendImage(fromCamera: false);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt,
                    label: LanguageService.get("camera"),
                    onTap: () {
                      Navigator.pop(context);
                      model.pickAndSendImage(fromCamera: true);
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.file_present,
                    label: LanguageService.get("document"),
                    onTap: () {
                      Navigator.pop(context);
                      model.pickAndSendDocument();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.location_on,
                    label: LanguageService.get("location"),
                    onTap: () {
                      Navigator.pop(context);
                      model.sendLocation();
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.link,
                    label: LanguageService.get("external_link"),
                    onTap: () {
                      Navigator.pop(context);
                      _showLinkDialog(context, model);
                    },
                  ),
                  Container(width: 60),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLinkDialog(BuildContext context, ChatViewModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(LanguageService.get("share_link")),
          content: TextField(
            controller: model.linkController,
            decoration: InputDecoration(
              labelText: LanguageService.get("enter_url"),
              hintText: 'https://example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () {
                model.linkController.clear();
                Navigator.pop(context);
              },
              child: Text(LanguageService.get("cancel")),
            ),
            ElevatedButton(
              onPressed: () {
                if (model.linkController.text.trim().isNotEmpty) {
                  model.sendLink(model.linkController.text.trim());
                  model.linkController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text(LanguageService.get("send")),
            ),
          ],
        );
      },
    );
  }

  void _showCameraOptions(BuildContext context, ChatViewModel model) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.v20),
              topRight: Radius.circular(AppSizes.v20),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LanguageService.get("take_photo"),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCameraOption(
                    icon: Icons.camera_alt,
                    label: LanguageService.get("camera"),
                    onTap: () {
                      Navigator.pop(context);
                      model.pickAndSendImage(fromCamera: true);
                    },
                  ),
                  _buildCameraOption(
                    icon: Icons.video_camera_back,
                    label: LanguageService.get("video"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(icon, color: Colors.indigo),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _startAudioRecording(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LanguageService.get("audio_recording")),
          content: Text(LanguageService.get("audio_recording_coming_soon")),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LanguageService.get("ok")),
            ),
          ],
        );
      },
    );
  }

  void _buildConfirmationDialog(BuildContext context, model) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
                SizedBox(height: 16),
                Text(
                  "${LanguageService.get("ticket_on_hold")} ${getUser().organizationType == OrganizationType.manufacturer ? LanguageService.get("resume") : ""} ${LanguageService.get("send_message")}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF042c74),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Color(0xFF042c74)),
                          ),
                        ),
                        child: Text(LanguageService.get("no")),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (getUser().organizationType == OrganizationType.manufacturer) {
                            await model.reopenTicket(model.ticket!.id);
                          }
                          await model.sendMessage();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF042c74),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(LanguageService.get("yes")),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}