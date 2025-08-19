import 'package:flutter/material.dart';
import 'package:manager/core/models/hive/user/user.dart';
import 'package:manager/core/storage/storage.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import 'ticket_card/ticket_card.dart';
import 'tickets_list.vm.dart';

class TicketsListView extends StatefulWidget {
  const TicketsListView({super.key});

  @override
  State<TicketsListView> createState() => _TicketsListViewState();
}

class _TicketsListViewState extends State<TicketsListView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
      builder: (
          BuildContext context,
          TicketsListViewModel model,
          Widget? child,
          ) {
        // Determine the number of tabs based on user type
        final isManufacturer = getUser().organizationType == OrganizationType.manufacturer;
        final tabCount = isManufacturer ? 3 : 2;

        return DefaultTabController(
          length: tabCount, // Dynamically set tab count
          child: Scaffold(
            backgroundColor: AppColors.transparent,
            appBar: _buildAppBar(context, model),
            body:
            Container(
              color: AppColors.white,
              child: SafeArea(
                child: Column(
                  children: [
                    // Animated search bar
                    SlideTransition(
                      position: _slideAnimation,
                      child: _isSearchVisible
                          ? _buildSearchBar(context, model)
                          : const SizedBox.shrink(),
                    ),
                    // Tab Bar
                    Container(
                      color: AppColors.white,
                      child: TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.gray,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(text: LanguageService.get("active_tickets")),

                          // if(isManufacturer) Tab(text: 'Pending Remark'),
                          Tab(text: LanguageService.get("resolved_tickets")),
                        ],
                        onTap: (index) {
                          // Update the current tab index in the view model
                          model.selectedTabIndex = index;
                        },
                      ),
                    ),
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Active Tickets Tab (OnHold and InProgress)
                          RefreshIndicator(
                            onRefresh: () async => model.loadTickets(),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child: model.isLoading
                                ? _buildLoadingShimmer()
                                : model.activeTickets.isEmpty
                                ? _buildEmptyState(context, model, isActive: true)
                                : _buildTicketsList(context, model, model.activeTickets),
                          ),

                          // if(isManufacturer)
                          //   RefreshIndicator(
                          //     onRefresh: () async => model.loadTickets(),
                          //     color: AppColors.primary,
                          //     backgroundColor: AppColors.white,
                          //     child: model.isLoading
                          //         ? _buildLoadingShimmer()
                          //         : model.pendingRemarkTickets.isEmpty
                          //         ? _buildEmptyState(context, model, isActive: true)
                          //         : _buildTicketsList(context, model, model.pendingRemarkTickets),
                          //   ),

                          // Resolved Tickets Tab
                          RefreshIndicator(
                            onRefresh: () async => model.loadTickets(),
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child: model.isLoading
                                ? _buildLoadingShimmer()
                                : model.resolvedTickets.isEmpty
                                ? _buildEmptyState(context, model, isActive: false)
                                : _buildTicketsList(context, model, model.resolvedTickets),
                          ),

                          // Only include the Pending Remark tab if user is manufacturer
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: model.isProcessor && model.selectedTabIndex == 0
                ? FloatingActionButton(
              onPressed: () => model.navigateToCreateOrEditTicketView(),
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add, color: AppColors.white),
            )
                : null,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      TicketsListViewModel model,
      ) {
    return AppBar(
      elevation: 0,
      // surfaceTintColor: AppColors.primary,
      // backgroundColor: AppColors.primary,
      // iconTheme: IconThemeData(color: AppColors.white),
      title: Text(
        LanguageService.get("support_tickets"),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleSearch,
          icon: Icon(
            _isSearchVisible ? Icons.close : Icons.search,
            color: AppColors.white,
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.white),
          tooltip: 'Refresh',
          onPressed: () => model.loadTickets(),
        ),

        SizedBox(width: AppSizes.w8),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TicketsListViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
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
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          fillColor: AppColors.lightGray.withValues(alpha: 0.3),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.v12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: AppSizes.h12,
            horizontal: AppSizes.w16,
          ),
          suffixIcon: _searchController.text.isNotEmpty
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h20,
      ),
      itemCount: 5, // Number of shimmer items to show
      itemBuilder: (context, index) {
        return TicketCardShimmer();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TicketsListViewModel model, {required bool isActive}) {
    String mainText = isActive ? LanguageService.get('no_active_tickets_found') :LanguageService.get('no_resolved_tickets_found');
    String subText = isActive
        ? LanguageService.get('create_a_ticket_to_get_support')
        : LanguageService.get('all_your_resolved_tickets_will_appear_here');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.v24),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.support_agent_outlined : Icons.check_circle_outline,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSizes.h20),
          Text(
            mainText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSizes.h8),
          if (getUser().organizationType == OrganizationType.processor && isActive)
            Column(
              children: [
                // Text(
                //   subText,
                //   style: Theme.of(
                //     context,
                //   ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                // ),
                SizedBox(height: AppSizes.h30),
                ElevatedButton.icon(
                  onPressed: () => model.navigateToCreateOrEditTicketView(),
                  icon: Icon(Icons.add, color: AppColors.white),
                  label: Text(
                    LanguageService.get("create_ticket"),
                    style: TextStyle(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.w24,
                      vertical: AppSizes.h12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.v12),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              subText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(BuildContext context, TicketsListViewModel model, List<TicketCardAttributes> tickets) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w20,
        vertical: AppSizes.h16,
      ),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return TicketCard(attributes: ticket);
      },
    );
  }
}