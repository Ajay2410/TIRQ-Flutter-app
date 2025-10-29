import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:manager/services/language.service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';
import '../../core/models/rating_ticket_list_model.dart';
import 'feedback_ratings.vm.dart';

class FeedbackRatingsView extends StatefulWidget {
  const FeedbackRatingsView({super.key});

  @override
  State<FeedbackRatingsView> createState() => _FeedbackRatingsViewState();
}

class _FeedbackRatingsViewState extends State<FeedbackRatingsView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  AnimationController? _fabAnimationController;
  bool _isSearchVisible = false;
  final Set<String> _expiredTicketIds = {}; // Track which tickets have already triggered refresh

  // Dynamic border radius for segmented control
  BorderRadius _dynamicBorder = BorderRadius.only(
    topLeft: Radius.circular(AppSizes.v45),
    bottomLeft: Radius.circular(AppSizes.v45),
  );

  @override
  void initState() {
    super.initState();

    // Initialize search animation controller
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // FAB animation controller will be initialized lazily when needed
  }

  void _clearExpiredTicketIds() {
    _expiredTicketIds.clear();
  }

  Future<void> _refreshTickets(FeedbackRatingsViewModel model) async {
    _clearExpiredTicketIds();
    await model.loadTickets(forceRefresh: true);
  }

  @override
  void dispose() {
    // Dispose animation controllers first
    _animationController.dispose();
    _fabAnimationController?.dispose();

    // Dispose text controllers
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _toggleSearch() {
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeedbackRatingsViewModel>.reactive(
      viewModelBuilder: () => FeedbackRatingsViewModel(),
      onViewModelReady: (FeedbackRatingsViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, FeedbackRatingsViewModel model, Widget? child) {
        return Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: _buildAppBar(context, model),
          body: Container(
            color: AppColors.white,
            child: SafeArea(
              child: Column(
                children: [
                  // Animated search bar
                  SlideTransition(
                    position: _slideAnimation,
                    child: _isSearchVisible ? _buildSearchBar(context, model) : const SizedBox.shrink(),
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: RefreshIndicator(
                        onRefresh: () async => _refreshTickets(model),
                        color: AppColors.primary,
                        backgroundColor: AppColors.white,
                        child:
                            model.isLoading && model.resolvedTickets.isEmpty
                                ? _buildLoadingShimmer()
                                : model.resolvedTickets.isEmpty
                                ? _buildEmptyState(context, model, isActive: false)
                                : _buildTicketsListWithPagination(
                                  context,
                                  model,
                                  model.resolvedTickets,
                                  isActive: false,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FeedbackRatingsViewModel model) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primaryDark],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            stops: [0.08, 1],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => model.navigateBack(),
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
      ),
      title: Text(
        LanguageService.get("feedback_ratings"),
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        InkWell(
          onTap: _toggleSearch,
          child: Image.asset(AppImages.search, width: 21, height: 21, color: AppColors.white),
        ),
        SizedBox(width: 20),
        InkWell(
          onTap: () => model.loadTickets(),
          child: Image.asset(AppImages.refresh, width: 21, height: 21, color: AppColors.white),
        ),
        SizedBox(width: AppSizes.w8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, FeedbackRatingsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w20, vertical: AppSizes.h16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), offset: const Offset(0, 2), blurRadius: 8),
        ],
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
          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.primary),
          ),
          fillColor: AppColors.lightGrey.withValues(alpha: 0.3),
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

  Widget _buildEmptyState(BuildContext context, FeedbackRatingsViewModel model, {required bool isActive}) {
    String mainText =
        isActive ? LanguageService.get('no_active_tickets_found') : LanguageService.get('no_resolved_tickets_found');
    String subText =
        isActive
            ? LanguageService.get('create_a_ticket_to_get_support')
            : LanguageService.get('all_your_resolved_tickets_will_appear_here');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(color: AppColors.lightGrey.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: Icon(
              isActive ? Icons.support_agent_outlined : Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            mainText,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: AppSizes.h8),
          if (isActive)
            SizedBox()
          else
            Text(subText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTicketsListWithPagination(
    BuildContext context,
    FeedbackRatingsViewModel model,
    List<RatingList> tickets, {
    required bool isActive,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!model.isLoadingMore &&
            model.hasMoreTickets &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
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
          return _buildTicketCard(context, ticket, model);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, FeedbackRatingsViewModel model) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h16),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.v16),
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, RatingList ticket, FeedbackRatingsViewModel model) {
    return GestureDetector(
      onTap: () {
        //TODO:  don't remove
        // if (ticket.paymentStatus == 'paid') {
        model.navigateToTicketDetails(ticketId: ticket.sId ?? '', context: context);
        // } else {
        //   model.navigateToReviewTicketWithId(ticketId: ticket.id ?? '');
        // }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.h10),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.v12),
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
                                ticket.processor?.fullName ?? '-',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
                                ticket.status ?? '-',
                                style: TextStyle(
                                  color: _getStatusColorFromString(ticket.status),
                                  fontSize: AppSizes.v12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppGaps.h8,
              Divider(),
              AppGaps.h8,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.get("rating"),
                              style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey, fontWeight: FontWeight.bold),
                            ),
                        buildStarRating(rating: double.parse(ticket.rating ?? "0").toInt()),
                          ],
                        ),
                        Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.softGray,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
                          ),
                          child: Image.asset(AppImages.arrowRight, width: 16, height: 16, color: AppColors.darkGray),
                        ),
                      ],
                    ),
                    if((ticket.feedback ?? "").isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LanguageService.get("feedback"),
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textGrey, fontWeight: FontWeight.bold),
                        ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.textGrey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ticket.feedback ?? "",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStarRating({
    required int rating,
    double size = 24,
    double spacing = 4,
  })
  {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) {
          final isFilled = index < rating;
          return Padding(
            padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
            child: Container(
              width: size,
              height: size,
              color: Colors.white,
              padding: const EdgeInsets.all(2),
              child: SvgPicture.asset(
                isFilled
                    ? 'assets/svg/star_filled.svg'
                    : 'assets/svg/star_empty.svg',
                width: size - 4,
                height: size - 4,
                colorFilter: isFilled
                    ? null
                    : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildCountryFlag(BuildContext context, RatingList ticket) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.v16),
          ),
          alignment: Alignment.center,
          child: Text(
            ticket.processor?.fullName?.substring(0, 2).toUpperCase() ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.asset(AppImages.flag, width: 17, height: 17, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }


  Color _getStatusColorFromString(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'on hold':
        return Colors.red;
      case 'waiting for accept':
        return Colors.orange;
      default:
        return Colors.grey;
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
          baseColor: AppColors.lightGrey.withValues(alpha: 0.3),
          highlightColor: AppColors.lightGrey.withValues(alpha: 0.1),
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
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(AppSizes.v16),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2)),
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
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.w8, vertical: AppSizes.h2),
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(AppSizes.v8),
                              ),
                              child: Container(
                                height: 12,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
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
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    height: 12,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
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
              Container(height: 1, color: AppColors.lightGrey),
              AppGaps.h8,

              // Info columns section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildShimmerInfoColumn(), _buildShimmerInfoColumn(), _buildShimmerInfoColumn()],
              ),
              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGrey),
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
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                        SizedBox(height: 2),
                        Container(
                          height: 12,
                          width: 200,
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppGaps.h8,

              // Divider
              Container(height: 1, color: AppColors.lightGrey),

              // Action buttons section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6)),
                  ),
                  Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(2)),
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
        Container(
          height: 10,
          width: 60,
          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(height: 4),
        Container(
          height: 10,
          width: 40,
          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4)),
        ),
      ],
    );
  }
}
