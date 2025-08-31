import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/features/home/organization_home/organization_home.vm.dart';
import 'package:manager/services/language.service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';
import '../../../routes/routes.dart';

class OrganizationHomeView extends StatefulWidget {
  const OrganizationHomeView({super.key});

  @override
  State<OrganizationHomeView> createState() => _OrganizationHomeViewState();
}

class _OrganizationHomeViewState extends State<OrganizationHomeView> {
  String selectedUnit = 'Unit 1';
  int currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OrganizationHomeViewModel>.reactive(
      viewModelBuilder: () => OrganizationHomeViewModel(),
      onViewModelReady: (OrganizationHomeViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        OrganizationHomeViewModel model,
        Widget? child,
      ) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Stack(
              children: [
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Column(
                    children: [
                      Container(
                        height: Get.height * 0.3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primaryLight,
                            ],
                            stops: [0.0254, 1.0334],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [Expanded(child: _buildContent(context, model))],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, OrganizationHomeViewModel model) {
    String greeting = _getGreetingBasedOnTime();

    return Column(
      children: [
        // Blue header with user info and controls
        SizedBox(height: MediaQuery.of(context).padding.top),

        // Main header content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Profile picture
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child:
                      model.user.logoUrl != null
                          ? Image.network(
                            model.user.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildDefaultAvatar(),
                          )
                          : _buildDefaultAvatar(),
                ),
              ),

              SizedBox(width: 16),

              // Greeting and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      model.user.name ?? model.user.fullName ?? 'User',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Unit selector
              _buildDropdownFormField(
                context,
                value: selectedUnit,
                label: LanguageService.get('unit'),
                items: [
                  {"value": "Unit 1", "display": "Unit 1"},
                  {"value": "Unit 2", "display": "Unit 2"},
                  {"value": "Unit 3", "display": "Unit 3"},
                  {
                    "value": "+ Add New",
                    "display": LanguageService.get('add_new'),
                  },
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedUnit = newValue;
                    });
                  }
                },
                validator: null,
              ),
              SizedBox(width: 12),

              // Notification icon
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySuperLight.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 95,
          height: 56,
          child: Image.asset(AppImages.triqLogo3, fit: BoxFit.contain),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: AppColors.white, size: 24),
    );
  }

  Widget _buildContent(BuildContext context, OrganizationHomeViewModel model) {
    return Column(
      children: [
        _buildHeader(context, model),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDashboardCards(context, model),
                SizedBox(height: 30),
                _buildPromotionalBanner(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCards(
    BuildContext context,
    OrganizationHomeViewModel model,
  ) {
    // if (model.isLoading) {
    //   return Center(child: LottieBuilder.asset("assets/lotties/globe.json"));
    // }
    //
    // if (model.dashboard == null || model.dashboard!.cards.isEmpty) {
    //   return Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(Icons.dashboard_outlined, color: AppColors.gray, size: 50),
    //         SizedBox(height: 16),
    //         Text(
    //           "${LanguageService.get('no_dashboard_data')} ${LanguageService.get('or_not_added_to_any_organization')}",
    //           style: Theme.of(
    //             context,
    //           ).textTheme.titleMedium?.copyWith(color: AppColors.gray),
    //           textAlign: TextAlign.center,
    //         ),
    //         SizedBox(height: 16),
    //         TextButton(
    //           onPressed: () => model.fetchDashboardData(),
    //           child: Text(LanguageService.get("refresh")),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Column(
      children: [
        // First Card - Main Action Grid (2-row grid)
        _buildMainActionCard(context, model),

        SizedBox(height: 20),

        // Second Card - Secondary Features Grid (2-row grid)
        _buildSecondaryFeaturesCard(context, model),
      ],
    );
  }

  Widget _buildMainActionCard(
    BuildContext context,
    OrganizationHomeViewModel model,
  ) {
    final List<DashboardCardData> mainActions = [
      DashboardCardData(
        title: LanguageService.get('tickets_summary'),
        icon: AppImages.ticketSummary,
        color: AppColors.bluebackground,
        route: '/tickets',
      ),
      DashboardCardData(
        title: LanguageService.get('my_customers'),
        icon: AppImages.myCustomers,
        color: AppColors.bluebackground,
        route: '/customers',
      ),
      DashboardCardData(
        title: LanguageService.get('my_teams'),
        icon: AppImages.myTeam,
        color: AppColors.greenbackground,
        route: '/teams',
      ),
      DashboardCardData(
        title: LanguageService.get('tasks'),
        icon: AppImages.tasks,
        color: AppColors.redbackground,
        route: '/tasks',
      ),
      DashboardCardData(
        title: LanguageService.get('pi_invoice'),
        icon: AppImages.piInvoice,
        color: AppColors.darkGreenBack,
        route: '/pi-invoice',
        isComingSoon: true,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: mainActions.length,
            itemBuilder: (context, index) {
              final card = mainActions[index];
              return _buildDashboardCard(context, card, index, model);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryFeaturesCard(BuildContext context, OrganizationHomeViewModel model) {
    final List<DashboardCardData> secondaryFeatures = [
      DashboardCardData(
        title: LanguageService.get('analytics_dashboard'),
        icon: AppImages.analyticsDashboard,
        color: AppColors.yellow,
        route: '/analytics',
      ),
      DashboardCardData(
        title: LanguageService.get('machine_records'),
        icon: AppImages.machineRecords,
        color: AppColors.redbackground,
        route: '/machines',
      ),
      DashboardCardData(
        title: LanguageService.get('feedback_rating'),
        icon: AppImages.feedbackRating,
        color: AppColors.greenbackground,
        route: '/feedback',
      ),
      DashboardCardData(
        title: LanguageService.get('installation_tracker'),
        icon: AppImages.installationTracker,
        color: AppColors.primarySuperLight,
        route: '/installations',
      ),
      DashboardCardData(
        title: LanguageService.get('feedback_survey'),
        icon: AppImages.feedbackSurvey,
        color: AppColors.yellow,
        route: '/survey',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: secondaryFeatures.length,
        itemBuilder: (context, index) {
          final card = secondaryFeatures[index];
          return _buildSecondaryFeatureCard(context, card, index, model);
        },
      ),
    );
  }

  Widget _buildSecondaryFeatureCard(
    BuildContext context,
    DashboardCardData card,
    int index,
    OrganizationHomeViewModel model,
  ) {
    return GestureDetector(
          onTap: () {
            // Navigate based on the card route
            if (card.route == '/machines') {
              // Navigate to Machine Records screen
              model.navigateToMachineRecords();
            }
            // TODO: Implement other navigation routes when needed
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with colored background
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Image.asset(
                    card.icon,
                    width: 25,
                    height: 25,
                    color: card.color,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Title
              Text(
                card.title,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
        .animate(delay: (index * 100).ms)
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          curve: Curves.easeOutQuad,
          duration: Duration(milliseconds: 200 + (index * 50)),
        );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    DashboardCardData card,
    int index,
    OrganizationHomeViewModel model,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate based on the card route
        if (card.route == '/customers') {
          // Navigate to My Customers screen using view model
          model.navigateToMyCustomers(context);
        }
        // TODO: Implement other navigation routes when needed
      },
      child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Image.asset(
                          card.icon,
                          width: 25,
                          height: 25,
                          color: card.color,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Title
                    Text(
                      card.title,
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                // Coming Soon badge
                if (card.isComingSoon)
                  Positioned(
                    top: -8,
                    right: -16,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        LanguageService.get('coming_soon'),
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          )
          .animate(delay: (index * 100).ms)
          .fadeIn(duration: 400.ms)
          .slideY(
            begin: 0.3,
            end: 0,
            curve: Curves.easeOutQuad,
            duration: Duration(milliseconds: 200 + (index * 50)),
          ),
    );
  }

  Widget _buildPromotionalBanner(BuildContext context) {
    final List<Map<String, dynamic>> carouselItems = [
      {
        'title': LanguageService.get('special_offer'),
        'subtitle': LanguageService.get('limited_time_only'),
        'description': LanguageService.get('up_to_80_off'),
        'colors': [AppColors.yellow, AppColors.yellow, AppColors.yellow],
        'imageUrl':
            'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=400&h=200&fit=crop',
      },
      {
        'title': LanguageService.get('new_features'),
        'subtitle': LanguageService.get('coming_soon_feature'),
        'description': LanguageService.get('enhanced_experience'),
        'colors': [
          AppColors.bluebackground,
          AppColors.greenbackground,
          AppColors.darkGreenBack,
        ],
        'imageUrl':
            'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400&h=200&fit=crop',
      },
      {
        'title': LanguageService.get('premium_support'),
        'subtitle': LanguageService.get('available_now'),
        'description': LanguageService.get('24_7_assistance'),
        'colors': [
          AppColors.bluebackground,
          AppColors.redbackground,
          AppColors.greenbackground,
        ],
        'imageUrl':
            'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=400&h=200&fit=crop',
      },
    ];

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 4),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                currentCarouselIndex = index;
              });
            },
          ),
          items:
              carouselItems.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        item['imageUrl'],
                        width: Get.width * 0.9,
                        height: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: item['colors'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        SizedBox(height: 12),
        // Carousel indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              carouselItems.asMap().entries.map((entry) {
                return Container(
                  width: currentCarouselIndex == entry.key ? 20 : 3,
                  height: 3,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        currentCarouselIndex == entry.key
                            ? AppColors.primary
                            : AppColors.gray.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  // Helper function to determine the appropriate greeting based on time of day
  String _getGreetingBasedOnTime() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return LanguageService.get('good_morning');
    } else if (hour < 17) {
      return LanguageService.get('good_afternoon');
    } else {
      return LanguageService.get('good_evening');
    }
  }

  Widget _buildDropdownFormField(
    BuildContext context, {
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isDense: true,
          value: value,
          hint: Text(
            label,
            style: TextStyle(color: AppColors.gray, fontSize: 12),
          ),
          onChanged: onChanged,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.black.withValues(alpha: 0.7),
            size: 16,
          ),
          dropdownColor: AppColors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          items:
              items.map<DropdownMenuItem<String>>((item) {
                bool isAddNew = item['value'] == '+ Add New';
                bool isSelected = item['value'] == value;

                return DropdownMenuItem<String>(
                  value: item['value'],
                  child:
                      isAddNew
                          ? Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColors.primary,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                item['display']!,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                          : Text(
                            item['display']!,
                            style: TextStyle(
                              color:
                                  isSelected ? AppColors.black : AppColors.gray,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

// Data class for dashboard cards
class DashboardCardData {
  final String title;
  final String icon;
  final Color color;
  final String route;
  final bool isComingSoon;

  DashboardCardData({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isComingSoon = false,
  });
}

class HomeCardShimmer extends StatelessWidget {
  const HomeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.only(bottom: 8),
      child: Shimmer.fromColors(
        baseColor: AppColors.lightGray.withValues(alpha: 0.4),
        highlightColor: AppColors.white,
        period: const Duration(milliseconds: 1500),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withValues(alpha: 0.2),
                blurRadius: 3,
                offset: const Offset(2, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Description lines
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 150,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 120,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const Spacer(),

              // Action button shimmer
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 12),
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSvgIcon extends StatelessWidget {
  final String svgName;
  final Color backgroundColor;
  final Color? iconColor;
  final String backgroundType;
  final double size;
  final bool isFilled;

  const CustomSvgIcon({
    super.key,
    required this.svgName,
    required this.backgroundColor,
    this.iconColor,
    this.backgroundType = "square",
    this.size = 10,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isFilled ? backgroundColor : Colors.transparent,
        borderRadius:
            backgroundType == "circle"
                ? BorderRadius.circular(size / 2)
                : BorderRadius.circular(size / 4),
        border: !isFilled ? Border.all(color: backgroundColor, width: 2) : null,
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/$svgName',
          width: size * 0.5,
          height: size * 0.5,
          colorFilter:
              iconColor != null
                  ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                  : null,
        ),
      ),
    );
  }
}
