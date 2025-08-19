import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:manager/features/profile/home/profile.vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/hive/user/user.dart';
import '../../../core/storage/storage.dart';
import '../../../services/language.service.dart';
import 'package:manager/features/profile/my_wallet/duepay.view.dart';
import 'package:manager/features/profile/my_wallet/general.view.dart';
import '../../stage/stage.view.dart';

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
          body:
          Container(
            color: AppColors.scaffoldBackground,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header Section - Fixed to match reference image
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

  PreferredSizeWidget _buildAppBar(BuildContext context, ProfileViewModel model) {
    return AppBar(
      backgroundColor: Colors.transparent, // Set to transparent
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed:  model.onBackPress,
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
          // Profile Image, Name/Email, and Completion Badge in one Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image with Edit Button
              Stack(
                children: [
                  Container(
                    width: 59,
                    height: 59,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF687FE5).withOpacity(0.3),
                          blurRadius: 2,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: model.user.logoUrl ??
                            'https://img.freepik.com/free-vector/search-engine-logo_1071-76.jpg',
                        width: 61,
                        height: 61,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFFE8E8E8),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
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
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
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
              // Completion Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '32% Completed',
                  style: TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
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
                    child:
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 24,
                          color: Color(0xFF2196F3),
                        ),
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
                    child:
                    Row(
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
            icon: Icons.business_outlined,
            title: getUser().userRole == UserRole.superAdmin
                ? LanguageService.get("organization")
                : LanguageService.get("profile"),
            iconColor: const Color(0xFF9C27B0),
            iconBgColor: const Color(0xFFF3E5F5),
            onTap: getUser().userRole == UserRole.superAdmin
                ? model.navigateToCreateOrEditOrgView
                : model.navigateToEmployeeProfileView,
            animationDelay: 500.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: LanguageService.get("general"),
            iconColor: const Color(0xFF00BCD4),
            iconBgColor: const Color(0xFFE0F2F1),
            onTap: model.navigateToGeneralSetting,
            animationDelay: 600.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: LanguageService.get("security"),
            iconColor: const Color(0xFF607D8B),
            iconBgColor: const Color(0xFFECEFF1),
            onTap: () {},
            animationDelay: 700.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: LanguageService.get("help_and_support"),
            iconColor: const Color(0xFFFF9800),
            iconBgColor: const Color(0xFFFFF3E0),
            onTap: () {},
            animationDelay: 800.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.feedback_outlined,
            title: LanguageService.get("feedback"),
            iconColor: const Color(0xFF673AB7),
            iconBgColor: const Color(0xFFEDE7F6),
            onTap: () {},
            animationDelay: 900.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.person_add_outlined,
            title: LanguageService.get("invite_a_contact"),
            iconColor: const Color(0xFF4CAF50),
            iconBgColor: const Color(0xFFE8F5E8),
            onTap: () {},
            animationDelay: 1000.ms,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout_outlined,
            title: LanguageService.get("logout"),
            iconColor: const Color(0xFFE53935),
            iconBgColor: const Color(0xFFFFEBEE),
            onTap: model.navigateToLoginView,
            isLast: true,
            animationDelay: 1100.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBgColor,
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.textGray.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.black,
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

  Widget _buildTermsAndPolicy(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: LanguageService.get("by_using_this_app_you_agree_to_our"),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: LanguageService.get("terms_conditions"),
              style: const TextStyle(
                color: Color(0xFF4A6CF7),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4A6CF7),
              ),
            ),
            TextSpan(text: LanguageService.get("and")),
            TextSpan(
              text: LanguageService.get("privacy_policy"),
              style: const TextStyle(
                color: Color(0xFF4A6CF7),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4A6CF7),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 1000.ms);
  }
}