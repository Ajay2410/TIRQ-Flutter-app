import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/models/ticket.dart';
import 'package:intl/intl.dart';
import 'package:manager/core/utils/app_logger.dart';

import '../../../../core/storage/storage.dart';
import '../../../../core/utils/helpers/helpers.dart';
import '../../../../resources/app_resources/app_resources.dart';
import '../../../../services/language.service.dart';

class TicketCardAttributes {
  final String id;
  final String customerName;
  final Ticket ticket;
  final String countryCode;
  final String machineName;
  final String elapsedTime;
  final String errorDescription;
  final Function(String) onTicketTap;
  final Function(String)? onAddRemarkTap;

  // Keeping these properties for compatibility, but removing UI elements that use them
  final String? lastPingTime;
  final Function()? onPingPressed;
  final Function()? onChatPressed;

  // Method to check if pinging is allowed (5 minutes have passed since last ping)
  bool get canPing {
    return true;
  }

  // Method to calculate remaining time till next ping
  String get remainingPingTime {
    if (lastPingTime == null) return '0:00';

    try {
      final lastPingDateTime = DateTime.parse(lastPingTime!);
      final now = DateTime.now();
      DateTime nextPingTime = lastPingDateTime.add(Duration(minutes: 5));
      if (lastPingDateTime.isAfter(now)) {
        nextPingTime = lastPingDateTime;
      }

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

  TicketCardAttributes({
    required this.id,
    required this.ticket,
    required this.customerName,
    required this.countryCode,
    required this.machineName,
    required this.elapsedTime,
    required this.errorDescription,
    required this.onTicketTap,
    this.lastPingTime,
    this.onPingPressed,
    this.onChatPressed,
    this.onAddRemarkTap,
  });
}

class TicketCard extends StatefulWidget {
  const TicketCard({super.key, required this.attributes});

  final TicketCardAttributes attributes;

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild and update the remaining time
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.attributes.onTicketTap(widget.attributes.id),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.h10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [_buildCardHeader(context), _buildCardBody(context)],
        ),
      ),
    );
  }

  String _calculatePendingDuration(Ticket ticket) {
    if (ticket.createdAt == null) return 'Unknown';

    try {
      final createdAt = DateTime.parse(ticket.createdAt!);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays > 0) {
        return '${difference.inDays} ${LanguageService.get("days")} ${difference.inHours % 24} ${LanguageService.get("hours")}';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ${LanguageService.get("hours")} ${difference.inMinutes % 60} ${LanguageService.get("mins")}';
      } else {
        return '${difference.inMinutes} ${LanguageService.get("mins")}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildCardHeader(BuildContext context) {

    final isResolved = widget.attributes.ticket.status == 'Resolved';
    final pendingDuration = _calculatePendingDuration(widget.attributes.ticket);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h14,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.v16),
          topRight: Radius.circular(AppSizes.v16),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCountryFlag(context),
                SizedBox(width: AppSizes.w10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        widget.attributes.ticket.ticketId ??
                            widget.attributes.ticket.id,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.attributes.customerName,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.attributes.ticket.createdAt != null) ...[
                        SizedBox(height: 2),
                        Text(
                          _formatTicketDate(
                            widget.attributes.ticket.createdAt!,
                          ),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (widget.attributes.ticket.createdAt != null) ...[
                        SizedBox(height: 2),
                        Text(
                         '${LanguageService.get("pending_since")} : $pendingDuration',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]
                    ]
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppGaps.h10,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.w8,
                  vertical: AppSizes.h2,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.attributes.ticket.status ?? 'N/A',
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.v8),
                ),
                child: Text(
                  widget.attributes.ticket.status != null
                      ? formatStatus(widget.attributes.ticket.status !)
                      : 'N/A',
                  style: TextStyle(
                    color: _getStatusColor(
                      widget.attributes.ticket.status ?? 'N/A',
                    ),
                    fontSize: AppSizes.v12,
                  ),
                ),
              ),
              if (widget.attributes.ticket.status == 'Open' && widget.attributes.ticket.rescheduleTime != null && widget.attributes.ticket.rescheduleTime!.isAfter(DateTime.now().toUtc()))
                _buildRescheduleTimerBadge(context),
              if (widget.attributes.ticket.status == 'InProgress')
                ElevatedButton(
                  onPressed: widget.attributes.onChatPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: Size(60, 30),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(LanguageService.get("chat"), style: TextStyle(fontSize: 12)),
                ),
              if (widget.attributes.onPingPressed != null &&
                  widget.attributes.ticket.status == 'OnHold')
                Column(children: [AppGaps.h10, _buildTimerBadge(context)]),

              if(isResolved)
                ...[
                SizedBox(height: 10),
              Text(pendingDuration,
                  style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppSizes.v12,
                ),
              ),]
            ],
          ),
          // Removed all buttons from here
        ],
      ),
    );
  }

  Widget _buildRescheduleTimerBadge(BuildContext context) {
    String remainingRescheduledTime () {
      if (widget.attributes.ticket.rescheduleTime == null) return '0:00';

      try {
        final now = DateTime.now().toUtc();

        AppLogger.debug("$now - ${widget.attributes.ticket.rescheduleTime!}");

        final remaining = widget.attributes.ticket.rescheduleTime!.difference(now);
        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;

        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds
            .toString().padLeft(2, '0')}';
      } catch (e) {
        return '0:00';
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w10,
        vertical: AppSizes.h4,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        border: Border.all(
          color: AppColors.error,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSizes.v8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${LanguageService.get("rescheduled")}:${remainingRescheduledTime()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:  AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTimerBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w10,
        vertical: AppSizes.h4,
      ),
      decoration: BoxDecoration(
        color:
            widget.attributes.canPing
                ? AppColors.success.withValues(alpha: 0.15)
                : AppColors.error.withValues(alpha: 0.15),
        border: Border.all(
          color:
              widget.attributes.canPing ? AppColors.success : AppColors.error,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSizes.v20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.attributes.canPing
                ? widget.attributes.elapsedTime
                : widget.attributes.remainingPingTime,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  widget.attributes.canPing
                      ? AppColors.success
                      : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTicketDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat('MMM d, y • h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCountryFlag(BuildContext context) {
    // This is a placeholder for an actual flag implementation
    // You would typically use a package like country_icons or flag to display actual flags
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.v10),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.attributes.countryCode,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
      case 'inprogress':
        return Colors.red;
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

  Widget _buildCardBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.v16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded(
              //   child: _buildInfoItem(
              //     context,
              //     icon: Icons.confirmation_number_outlined,
              //     title: "Ticket ID",
              //     value:
              //         widget.attributes.ticket.ticketId ??
              //         widget.attributes.ticket.id,
              //   ),
              // ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.precision_manufacturing_outlined,
                  title: LanguageService.get("model_number"),
                  value: widget.attributes.machineName,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  context,
                  icon: Icons.verified_outlined,
                  title: LanguageService.get("warranty_status"),
                  value: _getWarrantyStatus(widget.attributes.ticket),
                  valueColor:
                  _getWarrantyStatus(widget.attributes.ticket) ==
                      LanguageService.get("in_warranty")
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.h12),
          Row(
            children: [
              // Expanded(
              //   child: _buildInfoItem(
              //     context,
              //     icon: Icons.verified_outlined,
              //     title: "Warranty Status",
              //     value: _getWarrantyStatus(widget.attributes.ticket),
              //     valueColor:
              //         _getWarrantyStatus(widget.attributes.ticket) ==
              //                 "Under Warranty"
              //             ? AppColors.success
              //             : AppColors.error,
              //   ),
              // ),
              // Expanded(
              //   child: _buildInfoItem(
              //     context,
              //     icon: Icons.schedule,
              //     title:
              //         widget.attributes.ticket.status == 'Resolved'
              //             ? 'Closed at'
              //             : "Pending Time",
              //     value:
              //         widget.attributes.ticket.status == 'Resolved'
              //             ? _calculateClosedDuration(widget.attributes.ticket)
              //             : widget.attributes.elapsedTime,
              //     valueColor: AppColors.warning,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: AppSizes.h12),
          _buildErrorSection(context),
          SizedBox(height: AppSizes.h12),
          Divider(color: AppColors.lightGray, height: 1),
          SizedBox(height: AppSizes.h12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    LanguageService.get("details"),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: AppSizes.w4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateClosedDuration(Ticket ticket) {
    if (ticket.completedDate == null) return 'Unknown';

    try {
      return DateFormat('HH:mm, MMM dd').format(ticket.completedDate!);
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper method to determine warranty status
  String _getWarrantyStatus(Ticket ticket) {
    DateTime? startDate;
    DateTime? endDate;
    if (ticket.machine?.warranty != null) {
      startDate = DateTime.parse(
        ticket.machine?.warranty?.startDate ??
            DateTime.now().toUtc().toIso8601String(),
      );
      endDate = DateTime.parse(
        ticket.machine?.warranty?.expirationDate ??
            DateTime.now().toUtc().toIso8601String(),
      );
    }
    String status = 'N/A';
    if (startDate != null && endDate != null) {
      if (DateTime.now().isAfter(startDate) &&
          DateTime.now().isBefore(endDate)) {
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
        return LanguageService.get("expired");
      default:
        return "N/A";
    }
  }

  Widget _buildErrorSection(BuildContext context) {
    final hasAttachments =
        widget.attributes.ticket.attachments != null &&
        widget.attributes.ticket.attachments!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: AppColors.error),
            SizedBox(width: 6),
            Text(
              LanguageService.get("error_problem"),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasAttachments) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo, size: 12, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      "${widget.attributes.ticket.attachments!.length}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.v10),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppSizes.v8),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            widget.attributes.errorDescription,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.attributes.ticket.closingRemark != null && widget.attributes.ticket.status == 'Resolved') ...[
          SizedBox(height: 6),
          Row(
            children: [
              Text(
                LanguageService.get("closing_remarks"),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.v10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSizes.v8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              widget.attributes.ticket.closingRemark!,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if ( widget.attributes.onAddRemarkTap!=null && widget.attributes.ticket.status == 'Pending' && getUser().organizationType == OrganizationType.manufacturer) ...[
          SizedBox(height: 6),
          Row(
            children: [
              Text(
                LanguageService.get("closing_remarks"),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          GestureDetector(
            onTap:()=> widget.attributes.onAddRemarkTap!(widget.attributes.ticket.id),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.v10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.v8),
              ),
              child: Text(
                LanguageService.get("click_here_add_closing_remark"),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        if (hasAttachments &&
            widget.attributes.ticket.attachments!.length <= 3) ...[
          SizedBox(height: 8),
          _buildAttachmentPreviews(widget.attributes.ticket.attachments!),
        ],
      ],
    );
  }

  Widget _buildAttachmentPreviews(List<String> attachments) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length > 3 ? 3 : attachments.length,
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemBuilder: (context, index) {
          // For the last item if there are more than 3 attachments
          if (index == 2 && attachments.length > 3) {
            return Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(attachments[index]),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "+${attachments.length - 2}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          }

          // Regular attachment preview
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(attachments[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// Shimmer loading state for the ticket card
class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementation of shimmer loading effect
    // This would use the shimmer package as in your original code
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h10),
      height: 180, // Approximate height of a ticket card
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}
