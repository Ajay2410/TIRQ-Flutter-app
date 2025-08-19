import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:manager/core/models/widgets/home/home_card_model.dart';
import 'package:manager/features/home/organization_home/organization_home.vm.dart';
import 'package:manager/services/language.service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';
import '../../../resources/multimedia_resources/resources.dart';

class OrganizationHomeView extends StatelessWidget {
  const OrganizationHomeView({super.key});

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
        final ScrollController scrollController = ScrollController();

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              Container(
                  child: Column(
                    children: [
                      _buildHeaderBackground(context, model, scrollController),
                      _buildLowerBackground(context),
                    ],
                  )
              ),
              _buildContent(context, model, scrollController),
              // Animated AppBar that disappears on scroll
              _buildAnimatedAppBar(context, model, scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAppBar(BuildContext context, OrganizationHomeViewModel model, ScrollController scrollController) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        // Calculate opacity based on scroll position
        double opacity = 1.0;
        if (scrollController.hasClients) {
          // Start fading out after scrolling 50 pixels
          double fadeStartOffset = 50.0;
          // Complete fade out at 150 pixels
          double fadeEndOffset = 150.0;

          if (scrollController.offset >= fadeStartOffset) {
            opacity = 1.0 - ((scrollController.offset - fadeStartOffset) / (fadeEndOffset - fadeStartOffset));
            opacity = opacity.clamp(0.0, 1.0);
          }
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: Duration(milliseconds: 100),
            child: Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
              child: _buildAppBarContent(context, model),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarContent(BuildContext context, OrganizationHomeViewModel model) {
    String greeting = _getGreetingBasedOnTime();

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        children: [
          // Profile picture
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: model.user.logoUrl != null
                  ? Image.network(
                model.user.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),
          SizedBox(width: AppSizes.w8),
          // Weather icon and greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  model.user.name ?? model.user.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
          // Unit selector
          Container(
            width: 70,
            padding: EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unit 1',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.black.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
          ),
          // Notification icon
          SizedBox(width: AppSizes.w16),
          Container(
            margin: EdgeInsets.only(right: 0),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowerBackground(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: double.infinity,
    );
  }

  Widget _buildHeaderBackground(BuildContext context, OrganizationHomeViewModel model, ScrollController scrollController) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Center(
          child: _buildProfileLogo(),
        ),
      ),
    );
  }

  // Helper method to build default avatar
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.white,
        size: 24,
      ),
    );
  }

  Widget _buildProfileLogo() {
    return Container(
      width: AppSizes.v110,
      height: AppSizes.v65,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.triqLogo3),
          fit: BoxFit.cover,
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildContent(
      BuildContext context,
      OrganizationHomeViewModel model,
      ScrollController scrollController,
      ) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 5),
          AnimatedBuilder(
            animation: scrollController,
            builder: (context, child) {
              double opacity = (scrollController.hasClients
                  ? (scrollController.offset /
                  (MediaQuery.of(context).size.height / 4))
                  : 0.0)
                  .clamp(0.0, 1.0);
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.lerp(
                      BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.v30),
                        topRight: Radius.circular(AppSizes.v30),
                      ),
                      BorderRadius.zero,
                      opacity,
                    ),
                    color: AppColors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizes.h10),
                      _buildCardGrid(context, model),
                      SizedBox(height: AppSizes.h30),
                      _buildCarouselSection(context),
                      SizedBox(height: AppSizes.h20 + kBottomNavigationBarHeight),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to determine the appropriate greeting based on time of day
  String _getGreetingBasedOnTime() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return ' 🌞 ${LanguageService.get("GOOD_MORNING")}';
    } else if (hour < 17) {
      return '🌤️ ${LanguageService.get("GOOD_AFTERNOON")}';
    } else {
      return ' 🌆 ${LanguageService.get("GOOD_EVENING")}';
    }
  }

  Widget _buildCardGrid(BuildContext context, OrganizationHomeViewModel model) {
    if (model.isLoading) {
      return LottieBuilder.asset("assets/lotties/globe.json");
    }

    if (model.dashboard == null || model.dashboard!.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              color: AppColors.gray,
              size: AppSizes.v50,
            ),
            SizedBox(height: AppSizes.h16),
            Text(
              "${LanguageService.get('no_dashboard_data')} ${LanguageService.get('or_not_added_to_any_organization')}",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.gray,
              ),
            ),
            SizedBox(height: AppSizes.h10),
            TextButton(
              onPressed: () => model.fetchDashboardData(),
              child: Text(LanguageService.get("refresh")),
            ),
          ],
        ),
      );
    }

    // Split cards into sections
    final allCards = model.dashboard!.cards;
    final firstSectionCards = allCards.take(6).toList();
    final remainingCards = allCards.skip(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First section - First 6 cards
        if (firstSectionCards.isNotEmpty) ...[
          _buildCardSection(context, model, firstSectionCards, 0),
          if (remainingCards.isNotEmpty) SizedBox(height: AppSizes.h12),
        ],

        // Second section - Remaining cards
        if (remainingCards.isNotEmpty) ...[
          _buildCardSection(context, model, remainingCards, firstSectionCards.length),
        ],
      ],
    );
  }

  Widget _buildCardSection(
      BuildContext context,
      OrganizationHomeViewModel model,
      List<dynamic> cards,
      int startIndex,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.w16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSizes.h16,
          crossAxisSpacing: AppSizes.w16,
          childAspectRatio: 0.85,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final dashboardCard = cards[index];
          final homeCard = model.dashboardCardToHomeCard(dashboardCard);
          return _buildHomeCard(context, model, homeCard, startIndex + index);
        },
      ),
    );
  }

  Widget _buildHomeCard(
      BuildContext context,
      OrganizationHomeViewModel model,
      HomeCardModel homeCard,
      int index,
      ) {
    final cardColor = Color(homeCard.colorCode);

    return GestureDetector(
      onTap: () => model.navigateToRoute(homeCard.route, null),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.v16),
          splashColor: cardColor.withValues(alpha: 0.1),
          highlightColor: cardColor.withValues(alpha: 0.05),
          onTap: () => model.navigateToRoute(homeCard.route, null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.h8),
                width: AppSizes.v130,
                height: AppSizes.v110,
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.v16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      CustomSvgIcon(
                        svgName: homeCard.iconUrl ?? 'default_icon.svg',
                        backgroundColor: cardColor.withValues(alpha: 0.2),
                        iconColor: cardColor,
                        size: AppSizes.v55,
                        backgroundType: "circle",
                        isFilled: false,
                      ),
                      SizedBox(height: AppSizes.h10),
                      Text(
                        homeCard.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: AppColors.black,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildCarouselSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: AppSizes.w4, bottom: AppSizes.h12),
          child: Text(
            LanguageService.get("announcements"),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: 500.ms),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height / 4,
            viewportFraction: 1,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            pauseAutoPlayOnTouch: true,
          ),
          items: [
            _buildCarouselItem(
              'https://img.freepik.com/free-vector/black-friday-sale-banner-torn-paper-style-design_1017-34746.jpg',
              LanguageService.get("special_promotion"),
              Icons.discount_rounded,
            ),
            _buildCarouselItem(
              'https://img.freepik.com/free-vector/festa-junina-festival-banner_1017-19195.jpg?semt=ais_hybrid&w=740',
              LanguageService.get("upcoming_event"),
              Icons.event_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarouselItem(String imageUrl, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.v20),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(color: AppColors.lightGray),
              errorWidget:
                  (context, url, error) => Container(
                color: AppColors.lightGray,
                child: Icon(Icons.error, color: AppColors.gray),
              ),
            ),
          ).animate().fadeIn(duration: 500.ms),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.v20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(AppSizes.h16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(icon, color: AppColors.white, size: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeCardShimmer extends StatelessWidget {
  const HomeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.v20),
      ),
      margin: EdgeInsets.only(bottom: AppSizes.h8),
      child: Shimmer.fromColors(
        baseColor: AppColors.lightGray.withOpacity(0.4),
        highlightColor: AppColors.white,
        period: const Duration(milliseconds: 1500),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.v20),
            boxShadow: [
              BoxShadow(
                color: AppColors.gray.withOpacity(0.2),
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
                    width: AppSizes.w100,
                    height: AppSizes.h16,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.v4),
                    ),
                  ),
                  Container(
                    width: AppSizes.v24,
                    height: AppSizes.v24,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.h12),

              // Description lines
              Container(
                width: double.infinity,
                height: AppSizes.h10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.v4),
                ),
              ),
              SizedBox(height: AppSizes.h8),
              Container(
                width: AppSizes.w150,
                height: AppSizes.h10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.v4),
                ),
              ),
              SizedBox(height: AppSizes.h8),
              Container(
                width: AppSizes.w120,
                height: AppSizes.h10,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.v4),
                ),
              ),

              const Spacer(),

              // Action button shimmer
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(top: AppSizes.h12),
                  width: AppSizes.w80,
                  height: AppSizes.h24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.v16),
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
        borderRadius: backgroundType == "circle"
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(size / 4),
        border: !isFilled
            ? Border.all(color: backgroundColor, width: 2)
            : null,
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/$svgName',
          width: size * 0.5,
          height: size * 0.5,
          colorFilter: iconColor != null
              ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}