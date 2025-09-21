import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:manager/features/profile/home/profile.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../services/language.service.dart';
import '../../../routes/routes.dart';
import '../../../widgets/qr_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      onViewModelReady: (ProfileViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, ProfileViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: Container(
            color: AppColors.scaffoldBackground,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(context, model),
                  const SizedBox(height: 20),
                  // Menu Items
                  _buildMenuItems(context, model),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ProfileViewModel model,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      // Set to transparent
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => model.onBackPress,
      ),
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
      title: Text(
        LanguageService.get("my_profile"),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileViewModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildProfileCompletionCard(context, model),
          SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image with Edit Button
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.periwinkleBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.all(8),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl:
                            model.user.logoUrl ??
                            'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: const Color(0xFFE8E8E8),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: AppColors.textGray,
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  ).animate().scale(
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        model.navigateToCreateOrEditOrgView();
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Image.asset(
                          AppImages.edit,
                          width: 12,
                          height: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.organization?.name ??
                          model.user.name ??
                          'Leslie Alexander',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 4),
                    Text(
                      model.user.email ?? 'yourmail@email.com',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showQRDialog(model),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.textGray.withValues(alpha: 0.1),
                    ),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.asset(AppImages.qr, width: 32, height: 32),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: model.navigateToQRView,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code, size: 24, color: Color(0xFF2196F3)),
                        SizedBox(width: 12),
                        Text(
                          LanguageService.get("my_QR"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 24,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(width: 12),
                        Text(
                          LanguageService.get("my_wallet"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, ProfileViewModel model) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            imagePath: AppImages.organization,
            title: LanguageService.get("organization"),
            iconColor: AppColors.violetBlue,
            onTap: () {},
            animationDelay: 600.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.general,
            title: LanguageService.get("general"),
            iconColor: const Color(0xFF00BCD4),
            onTap: model.navigateToGeneralSetting,
            animationDelay: 600.ms,
          ),
          // Show Set Service Pricing only for organization roles
          if (getUser().primaryRole == UserRole.organization) ...[
            _buildDivider(),
            _buildMenuItem(
              imagePath: AppImages.organization,
              title: LanguageService.get("set_service_pricing"),
              iconColor: AppColors.organizationGreen,
              onTap: () {
                Navigator.pushNamed(context, Routes.setServicePricing);
              },
              animationDelay: 650.ms,
            ),
          ],
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.security,
            title: LanguageService.get("security"),
            iconColor: const Color(0xFF607D8B),
            onTap: () {},
            animationDelay: 700.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.helpSupport,
            title: LanguageService.get("help_and_support"),
            iconColor: const Color(0xFFFF9800),
            onTap: () {},
            animationDelay: 800.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.feedback,
            title: LanguageService.get("feedback"),
            iconColor: const Color(0xFF673AB7),
            onTap: () {},
            animationDelay: 900.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.inviteContact,
            title: LanguageService.get("invite_a_contact"),
            iconColor: const Color(0xFF4CAF50),
            onTap: () {},
            animationDelay: 1000.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            imagePath: AppImages.logout,
            title: LanguageService.get("logout"),
            iconColor: const Color(0xFFE53935),
            onTap: model.navigateToLoginView,
            isLast: true,
            animationDelay: 1100.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    IconData? icon,
    String? imagePath,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    required Duration animationDelay,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isLast ? 16 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    imagePath != null
                        ? Image.asset(
                          imagePath,
                          width: 24,
                          height: 24,
                          color: iconColor,
                          fit: BoxFit.contain,
                        )
                        : Icon(icon!, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySuperLight.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.textGray.withValues(alpha: 0.1),
                ),
              ),
              child: Image.asset(
                AppImages.arrowRight,
                width: 16,
                height: 16,
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: animationDelay);
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFEEEEEE),
    );
  }

  Widget _buildProfileCompletionCard(
    BuildContext context,
    ProfileViewModel model,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.get("please_complete_profile"),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 8),
                Text(
                  LanguageService.get("verify_email_phone_description"),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGray,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildCircularProgressIndicator(),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildCircularProgressIndicator() {
    const double completionPercentage =
        0.35; // 35% completion - can be made dynamic later
    // Test different percentages to verify color conditions:
    // 0.15 = 15% (Red), 0.45 = 45% (Orange), 0.75 = 75% (Blue), 1.0 = 100% (Green)

    return CircularPercentIndicator(
      radius: 30.0,
      lineWidth: 4.0,
      percent: completionPercentage,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${(completionPercentage * 100).toInt()}%",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            LanguageService.get("complete"),
            style: const TextStyle(fontSize: 8, color: AppColors.textGray),
          ),
        ],
      ),
      progressColor: _getProgressColor(completionPercentage),
      backgroundColor: Colors.white,
      circularStrokeCap: CircularStrokeCap.round,
    ).animate().scale(
      duration: 500.ms,
      delay: 300.ms,
      curve: Curves.easeOutBack,
    );
  }

  /// Returns the appropriate progress color based on completion percentage
  Color _getProgressColor(double percentage) {
    final int percentageInt = (percentage * 100).toInt();

    if (percentageInt >= 100) {
      return AppColors.progressGreen; // 100% Completed - Green
    } else if (percentageInt >= 70) {
      return AppColors.progressBlue; // 70-99% Completed - Blue
    } else if (percentageInt >= 31) {
      return AppColors.progressOrange; // 31-69% Completed - Orange
    } else {
      return AppColors.progressRed; // 0-30% Completed - Red
    }
  }

  void _showQRDialog(ProfileViewModel model) {
    Get.dialog(
      QRDialog(user: model.user, organizationName: model.organization?.name),
    );
  }
}
