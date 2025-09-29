import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manager/core/models/relationships.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/country_flag/country_helper.dart';

class CustomerCardAttributes {
  final VoidCallback onTap;
  final String leadingImageUrl;
  final String title;
  final String status;
  final String countryFlag;
  final Relationship relationship;

  CustomerCardAttributes({
    required this.onTap,
    required this.leadingImageUrl,
    required this.title,
    required this.status,
    required this.countryFlag,
    required this.relationship,
  });
}

class CustomerCard extends StatelessWidget {
  final CustomerCardAttributes attributes;

  const CustomerCard({super.key, required this.attributes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => attributes.onTap(),
      child: Container(
        padding: EdgeInsets.all(AppSizes.w16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v12),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildLeadingImage(),
            SizedBox(width: AppSizes.w11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          attributes.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isNewRelationship())
                        _buildNewTag(context),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getMachineModelsText(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.w12),
            _buildStatusBadge(context),
          ],
        ),
      ),
    );
  }

  bool _isNewRelationship() {
    if (attributes.relationship.requestedAt == null) {
      return false;
    }
    final confirmedAt = attributes.relationship.requestedAt!;
    final now = DateTime.now();
    final difference = now.difference(confirmedAt);
    return difference.inDays < 7;
  }

  Widget _buildNewTag(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: AppSizes.w8),
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w8,
        vertical: AppSizes.h4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.v12),
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      child: Text(
        'New',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  String _getMachineModelsText() {
    final machineModels = attributes.relationship.machineModels ?? [];
    if (machineModels.isEmpty) {
      return "Depart Name/ Tag line";
    } else {
      return machineModels.join(", ");
    }
  }

  Widget _buildLeadingImage() {
    return Stack(
      children: [
        Container(
          width: AppSizes.w55,
          height: AppSizes.w55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,  // Changed to circular
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.3),
              width: 5,
            ),
            color: AppColors.lightGrey.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.w48 / 2), // Circular clipping
            child: CachedNetworkImage(
              imageUrl: attributes.leadingImageUrl,
              width: AppSizes.w48,
              height: AppSizes.w48,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: AppSizes.w48,
                height: AppSizes.w48,
                color: AppColors.lightGrey.withOpacity(0.3),
                child: Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: AppSizes.w48,
                height: AppSizes.w48,
                color: AppColors.lightGrey.withOpacity(0.3),
                child: Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: _buildTrailingFlag(),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusText = attributes.status;
    final Color statusColor = _getStatusColor(statusText);
    final Color backgroundColor = _getStatusBackgroundColor(statusText);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w10,
        vertical: AppSizes.h6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.v6),
      ),
      child: Text(
        statusText.capitalize(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrailingFlag() {
    final String countryFlag = CountryHelper().getCountryFlagFromDialCode(
        attributes.relationship.partnerCountryCode ?? '+91');
    return Center(
      child: Text(
        countryFlag,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success.withValues(alpha: 0.15);
      case 'pending':
        return AppColors.warning.withValues(alpha: 0.15);
      case 'rejected':
        return AppColors.error.withValues(alpha: 0.15);
      default:
        return AppColors.gray.withValues(alpha: 0.15);
    }
  }
}

// Helper extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class CustomerCardShimmer extends StatelessWidget {
  const CustomerCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.h8),
      padding: EdgeInsets.all(AppSizes.w16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v12),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Leading image placeholder
          Container(
            width: AppSizes.w48,
            height: AppSizes.w48,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.v8),
            ),
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: AppSizes.h16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppSizes.v4),
                  ),
                ),
                SizedBox(height: AppSizes.h8),
                // Status placeholder
                Row(
                  children: [
                    Container(
                      width: AppSizes.w24,
                      height: AppSizes.w16,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppSizes.v4),
                      ),
                    ),
                    SizedBox(width: AppSizes.w8),
                    Container(
                      height: AppSizes.h12,
                      width: AppSizes.w100,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppSizes.v4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.w12),
          // Status badge placeholder
          Container(
            width: AppSizes.w60,
            height: AppSizes.h24,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.v16),
            ),
          ),
        ],
      ),
    );
  }
}