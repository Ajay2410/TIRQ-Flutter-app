import 'package:flutter/material.dart';
import 'package:manager/configs.dart';
import 'package:manager/core/models/customer.dart';
import 'package:manager/core/models/notification_model.dart';
import 'package:manager/core/utils/screen_utils.dart';
import 'package:manager/features/home/my_customers/machine_details/customer_details/customer_edit_details.view.dart';
import 'package:manager/features/home/notification/notification_vm.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationViewModel>.reactive(
      viewModelBuilder: () => NotificationViewModel(),
      onViewModelReady: (NotificationViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (BuildContext context, NotificationViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: Container(color: AppColors.white, child: _buildNotificationsList(context, model)),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, NotificationViewModel model) {
    return GradientAppBar(
      titleSpacing: 0,
      leading: IconButton(
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleKey: 'Notification',
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationViewModel model) {
    if (model.isLoading) {
      return _buildShimmerList();
    }

    if (model.hasError) {
      return _buildErrorState(context, model);
    }

    if (model.notifications.isEmpty) {
      return _buildEmptyState(context, model);
    }

    return RefreshIndicator(
      onRefresh: model.refreshNotifications,
      backgroundColor: AppColors.white,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider(color: AppColors.lightGrey, thickness: 1);
        },
        padding: const EdgeInsets.all(13),
        itemCount: model.notifications.length,
        itemBuilder: (context, index) {
          final notification = model.notifications[index];
          return _buildNotificationCard(notification, model, context);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(color: AppColors.lightGrey, thickness: 1);
      },
      padding: const EdgeInsets.all(13),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(baseColor: AppColors.lightGrey, highlightColor: AppColors.white, child: _buildNotificationCardShimmer());
      },
    );
  }

  Widget _buildNotificationCardShimmer() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGrey),
          child: Container(height: 50, width: 50, decoration: BoxDecoration(color: AppColors.lightGrey, shape: BoxShape.circle)),
        ),
        AppGaps.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
              AppGaps.h5,
              Container(height: 14, width: 200, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
              AppGaps.h5,
              Container(height: 12, width: 80, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(4))),
            ],
          ),
        ),
        AppGaps.w16,
        Container(height: 20, width: 60, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6))),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.redBack),
          AppGaps.h20,
          Text(
            LanguageService.get('error_loading_notifications'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          AppGaps.h10,
          Text(model.errorMessage ?? 'Unknown error', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
          AppGaps.h20,
          ElevatedButton(
            onPressed: model.refreshNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(LanguageService.get('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NotificationViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.alert, width: 80, height: 80, color: AppColors.gray),
          AppGaps.h20,
          Text(LanguageService.get('no_notifications_found'), style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationViewModel model, BuildContext context) {
    return InkWell(
      onTap: () => model.onNotificationTap(context, notification),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.colorF0F2FC),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(color: AppColors.bluebackground, shape: BoxShape.circle),
              child: ClipOval(
                child:
                    notification.userImage != null && notification.userImage!.isNotEmpty
                        ? Image.network(
                          "${Configurations().url}${notification.userImage}",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.bluebackground,
                              child: Center(
                                child: Text(
                                  notification.title?.substring(0, 2).toUpperCase() ?? 'NA',
                                  style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: AppColors.bluebackground,
                          child: Center(
                            child: Text(
                              notification.title?.substring(0, 2).toUpperCase() ?? 'NA',
                              style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
              ),
            ),
          ),

          AppGaps.w16,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? 'Unknown Notification',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, overflow: TextOverflow.ellipsis),
                ),
                AppGaps.h5,
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.body ?? "Connection Request",
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    AppGaps.w16,

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // Get the processorId from notification data
                            final processorId = notification.data?.processorId;
                            if (processorId == null || processorId.isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Invalid customer ID'), backgroundColor: AppColors.redBack));
                              }
                              return;
                            }

                            try {
                              // Show loading dialog while fetching customer data
                              final response = await model.fetchCustomerById(processorId);

                              if (response != null && mounted) {
                                // Navigate to CustomerEditDetailsView with notification flag
                                final editResult = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CustomerEditDetailsView(customer: response, isFromSearchOrganization: true),
                                  ),
                                );

                                // Handle result if needed
                                if (editResult != null) {
                                  // Refresh notifications or handle the result
                                  model.refreshNotifications();
                                }
                              } else if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Failed to fetch customer data'), backgroundColor: AppColors.redBack));
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.redBack));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                          ),
                        ),
                        SizedBox(width: 10.h),
                        GestureDetector(
                          onTap: () async {
                            // Get the notification ID
                            final notificationId = notification.id;
                            if (notificationId == null || notificationId.isEmpty) {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Invalid notification ID'), backgroundColor: AppColors.redBack));
                              }
                              return;
                            }

                            try {
                              // Show loading dialog while deleting notification
                              final success = await model.deleteNotification(notificationId);

                              if (success && mounted) {
                                // Show success message
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Notification rejected successfully'), backgroundColor: AppColors.success));

                                // Refresh notifications list
                                model.refreshNotifications();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.redBack));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(color: AppColors.redBack.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                            child: Text('Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.redBack)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
