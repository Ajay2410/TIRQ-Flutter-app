import 'dart:async';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:manager/services/language.service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/ticket_model.dart';
import '../../../core/enums/warranty_status_enum.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';
import '../../../widgets/common/info_column.dart';
import 'tickets_list.vm.dart';

class TicketsListView extends StatefulWidget {
  const TicketsListView({super.key});

  @override
  State<TicketsListView> createState() => _TicketsListViewState();
}

class _TicketsListViewState extends State<TicketsListView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  // Dynamic border radius for segmented control
  BorderRadius _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _animationController.forward();
      // Focus the search field after animation starts
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    } else {
      _animationController.reverse();
      _searchController.clear();
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketsListViewModel>.reactive(
      viewModelBuilder: () => TicketsListViewModel(),
      onViewModelReady: (TicketsListViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, TicketsListViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: _buildAppBar(context, model),
          body: Container(
            color: AppColors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Animated search bar
                  SlideTransition(position: _slideAnimation, child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink()),
                  // Tab Bar
                  Container(
                    color: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
                    child: CustomSlidingSegmentedControl<int>(
                      height: 40,
                      innerPadding: EdgeInsets.zero,
                      initialValue: model.selectedTabIndex,
                      decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(AppSizes.v45)),
                      padding: AppSizes.v4,

                      isStretch: true,
                      children: {
                        0: Text(
                          LanguageService.get("active_tickets"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: model.selectedTabIndex == 0 ? AppColors.white : AppColors.black,
                          ),
                        ),
                        1: Text(
                          LanguageService.get("resolved_tickets"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: model.selectedTabIndex == 1 ? AppColors.white : AppColors.black,
                          ),
                        ),
                      },
                      fromMax: true,
                      thumbDecoration: BoxDecoration(borderRadius: _dynamicBorder, color: AppColors.primary),
                      onValueChanged: (int value) {
                        // Update the current tab index in the view model
                        model.selectedTabIndex = value;

                        // Update dynamic border radius based on selected segment
                        setState(() {
                          switch (value) {
                            case 0:
                              _dynamicBorder = BorderRadius.only(topLeft: Radius.circular(AppSizes.v45), bottomLeft: Radius.circular(AppSizes.v45));
                              break;
                            case 1:
                              _dynamicBorder = BorderRadius.only(topRight: Radius.circular(AppSizes.v45), bottomRight: Radius.circular(AppSizes.v45));
                              break;
                          }
                        });
                      },
                    ),
                  ),
                  // Tab Content
                  Expanded(
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: IndexedStack(
                        index: model.selectedTabIndex,
                        children: [
                          // Active Tickets Tab
                          RefreshIndicator(
                            onRefresh: () async => model.loadTickets(forceRefresh: true),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child:
                                model.isLoading && model.activeTickets.isEmpty
                                    ? _buildLoadingShimmer()
                                    : model.activeTickets.isEmpty
                                    ? _buildEmptyState(context, model, isActive: true)
                                    : _buildTicketsListWithPagination(context, model, model.activeTickets, isActive: true),
                          ),

                          // Resolved Tickets Tab
                          RefreshIndicator(
                            onRefresh: () async => model.loadTickets(forceRefresh: true),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child:
                                model.isLoading && model.resolvedTickets.isEmpty
                                    ? _buildLoadingShimmer()
                                    : model.resolvedTickets.isEmpty
                                    ? _buildEmptyState(context, model, isActive: false)
                                    : _buildTicketsListWithPagination(context, model, model.resolvedTickets, isActive: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton:
              model.selectedTabIndex == 0
                  ? FloatingActionButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    onPressed: () {},
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.add, color: AppColors.white),
                  )
                  : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TicketsListViewModel model) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(onPressed: () => model.navigateToHome(), icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white)),
      title: Text(
        LanguageService.get("tickets_summary"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        InkWell(onTap: _toggleSearch, child: Image.asset(AppImages.search, width: 21, height: 21, color: AppColors.white)),
        SizedBox(width: 20),
        InkWell(onTap: () => model.loadTickets(), child: Image.asset(AppImages.refresh, width: 21, height: 21, color: AppColors.white)),
        SizedBox(width: AppSizes.w8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TicketsListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          model.searchQuery = value;
        },
        decoration: InputDecoration(
          hintText: LanguageService.get("search_tickets"),
          hintStyle: TextStyle(color: AppColors.gray),
          prefixIcon: Padding(padding: EdgeInsets.all(12), child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.primary)),
          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSizes.v12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: AppSizes.h12, horizontal: AppSizes.w16),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.gray),
                    onPressed: () {
                      _searchController.clear();
                      model.searchQuery = '';
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h20),
      itemCount: 5, // Number of shimmer items to show
      itemBuilder: (context, index) {
        return TicketCardShimmer();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TicketsListViewModel model, {required bool isActive}) {
    String mainText = isActive ? LanguageService.get('no_active_tickets_found') : LanguageService.get('no_resolved_tickets_found');
    String subText =
        isActive ? LanguageService.get('create_a_ticket_to_get_support') : LanguageService.get('all_your_resolved_tickets_will_appear_here');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(
              isActive ? Icons.support_agent_outlined : Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(mainText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: AppSizes.h8),
          if (isActive)
            Column(
              children: [
                SizedBox(height: AppSizes.h30),
                ElevatedButton.icon(
                  onPressed: () => model.navigateToCreateOrEditTicketView(),
                  icon: Icon(Icons.add, color: AppColors.white),
                  label: Text(LanguageService.get("create_ticket"), style: TextStyle(color: AppColors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.w24, vertical: AppSizes.h12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v12)),
                  ),
                ),
              ],
            )
          else
            Text(subText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTicketsListWithPagination(BuildContext context, TicketsListViewModel model, List<TicketModel> tickets, {required bool isActive}) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!model.isLoadingMore && model.hasMoreTickets && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          // User has scrolled near the bottom (within 200 pixels), load more tickets
          model.loadMoreTickets();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
        itemCount: tickets.length + (model.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tickets.length) {
            // Loading indicator at the bottom
            return _buildLoadingIndicator(context, model);
          }
          final ticket = tickets[index];
          return _buildTicketCard(context, ticket);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, TicketsListViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h16),
      child: Center(
        child: Padding(padding: EdgeInsets.all(AppSizes.v16), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketModel ticket) {
    final pendingDuration = _calculatePendingDuration(ticket);

    return GestureDetector(
      onTap: () => print("Tapped ticket: ${ticket.id}"),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.h10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.v10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCountryFlag(context, ticket),
                  SizedBox(width: AppSizes.w10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticket.processor?.fullName ?? 'N/A',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                              decoration: BoxDecoration(
                                color: _getStatusColorFromString(ticket.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.v8),
                              ),
                              child: Text(
                                ticket.status ?? 'N/A',
                                style: TextStyle(color: _getStatusColorFromString(ticket.status), fontSize: AppSizes.v12),
                              ),
                            ),
                          ],
                        ),
                        if (ticket.createdAt != null) ...[
                          SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text('${LanguageService.get("pending_since")} : ', style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                                    Text(pendingDuration, style: TextStyle(fontSize: 11, color: AppColors.black)),
                                  ],
                                ),
                              ),
                              Text(
                                "#${ticket.machine?.machineName ?? 'N/A'}",
                                style: TextStyle(fontSize: 10, color: AppColors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              Divider(),
              AppGaps.h8,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InfoColumn(label: LanguageService.get("created_date"), value: _formatTicketDate(ticket.createdAt!.toIso8601String())),
                  InfoColumn(label: LanguageService.get("error_code"), value: "#${ticket.errorCode ?? "N/A"}"),
                  InfoColumn(
                    label: LanguageService.get("warranty_status"),
                    value: ticket.warrantyStatus?.displayName ?? "N/A",
                    valueColor: _getWarrantyStatusColor(ticket.warrantyStatus),
                    valueFontWeight: FontWeight.w600,
                    valueFontSize: 10,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              AppGaps.h8,

              Divider(),
              AppGaps.h8,
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                        children: [
                          TextSpan(
                            text: "${LanguageService.get("problem_description")}: ",
                            style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: ticket.problem ?? ticket.notes ?? "N/A", style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              AppGaps.h8,
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (ticket.status == "Active") ...[
                    ElevatedButton(
                      onPressed:
                          ticket.status == "Active" || ticket.status == "In Progress" ? () => print("Chat pressed for ticket: ${ticket.id}") : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(60, 30),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      child: Text(LanguageService.get("chat_now"), style: TextStyle(fontSize: 12)),
                    ),
                    Spacer(),
                  ],

                  if (ticket.status == "Resolved") ...[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
                        ),
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                            children: [
                              TextSpan(
                                text: "${LanguageService.get("engineer_remarks")}: ",
                                style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ticket.problem ?? ticket.notes ?? "N/A", style: TextStyle(fontSize: 11, color: AppColors.textGray)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.softGray,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
                    ),
                    child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryFlag(BuildContext context, TicketModel ticket) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v16)),
          alignment: Alignment.center,
          child: Text(
            ticket.processor?.fullName?.substring(0, 2).toUpperCase() ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, width: 17, height: 17, fit: BoxFit.cover)),
        ),
      ],
    );
  }

  String _calculatePendingDuration(TicketModel ticket) {
    if (ticket.createdAt == null) return LanguageService.get('unknown');

    try {
      final createdAt = ticket.createdAt!;
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
      return LanguageService.get('unknown');
    }
  }

  String _formatTicketDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final formatter = DateFormat('MMM dd,yyyy HH:mm');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColorFromString(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getWarrantyStatusColor(WarrantyStatus? status) {
    if (status == null) return AppColors.error;

    switch (status) {
      case WarrantyStatus.available:
        return AppColors.success;
      case WarrantyStatus.assigned:
        return AppColors.primary;
      case WarrantyStatus.underMaintenance:
        return AppColors.error;
    }
  }
}

// Shimmer loading state for the ticket card
class TicketCardShimmer extends StatelessWidget {
  const TicketCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h10),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSizes.v10),
        child: Shimmer.fromColors(
          baseColor: AppColors.lightGray.withValues(alpha: 0.3),
          highlightColor: AppColors.lightGray.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header section with avatar and name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar shimmer
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(AppSizes.v16)),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: AppSizes.w10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(AppSizes.v8)),
                              child: Container(
                                height: 12,
                                width: 60,
                                decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    height: 12,
                                    width: 80,
                                    decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    height: 12,
                                    width: 60,
                                    decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGray),
              AppGaps.h8,

              // Info columns section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildShimmerInfoColumn(), _buildShimmerInfoColumn(), _buildShimmerInfoColumn()],
              ),
              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGray),
              AppGaps.h8,

              // Problem description section
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 2),
                        Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGray),

              // Action buttons section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 30, width: 80, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(6))),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 10, width: 60, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4))),
        SizedBox(height: 4),
        Container(height: 10, width: 40, decoration: BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.circular(4))),
      ],
    );
  }
}
