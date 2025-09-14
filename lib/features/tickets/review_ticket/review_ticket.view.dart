import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:shimmer/shimmer.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manager/core/models/review_ticket_model.dart';
import 'review_ticket.vm.dart';

class ReviewTicketView extends StatelessWidget {
  final String? ticketId;

  const ReviewTicketView({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReviewTicketViewModel>.reactive(
      viewModelBuilder: () => ReviewTicketViewModel(),
      onViewModelReady: (ReviewTicketViewModel model) => model.init(ticketId: ticketId),
      disposeViewModel: false,
      builder: (BuildContext context, ReviewTicketViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context),
          bottomNavigationBar: model.isLoading ? null : _buildBottomActionBar(context, model),
          body:
              model.isLoading
                  ? _buildShimmerContent()
                  : model.errorMessage != null
                  ? _buildErrorState(model.errorMessage!)
                  : SingleChildScrollView(
                    child: Container(
                      color: AppColors.scaffoldBackground,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTicketDetailsCard(context, model),
                          SizedBox(height: 16),
                          _buildSupportFeeNoticeCard(context, model),

                          Padding(padding: EdgeInsets.all(15), child: _buildPaymentCard(context, model)),

                          Padding(padding: EdgeInsets.only(left: 15, right: 15, bottom: 15), child: _buildCouponCodeCard(context, model)),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        LanguageService.get('review_ticket'),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTicketDetailsCard(BuildContext context, ReviewTicketViewModel model) {
    final ticketData = model.ticketData;
    if (ticketData == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppColors.lavenderMist, borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      ticketData.processorDetails?.fullName?.substring(0, 2).toUpperCase() ?? "",
                      style: const TextStyle(color: AppColors.colorBlue, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, height: 16, width: 16)),
                  ),
                ],
              ),
              SizedBox(width: AppSizes.v10),

              Expanded(
                child: Text(
                  ticketData.processorDetails?.fullName ?? "Unknown Organization",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),

              Container(height: 50, width: 1, color: AppColors.textGray.withValues(alpha: 0.1)),
              SizedBox(width: AppSizes.v10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('support_type'.lang, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 4),
                  Text(
                    ticketData.ticketDetails?.ticketType ?? "",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),

          Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildContactInfoRow('created_date'.lang, _formatDate(ticketData.ticketDetails?.createdAt))),
              const SizedBox(width: 10),
              Expanded(
                child: _buildContactInfoRow(
                  'warranty_status'.lang,
                  ticketData.customerMachineDetails?.warrantyStatus ?? "Unknown",
                  valueColor: _getWarrantyStatusColor(ticketData.customerMachineDetails?.warrantyStatus),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _buildContactInfoRow('machine_name'.lang, ticketData.machineDetails?.machineName ?? "Unknown Machine")),
            ],
          ),
          SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: _buildContactInfoRow('model_number'.lang, ticketData.machineDetails?.modelNumber ?? "Unknown Model"))],
          ),

          Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
              children: [
                TextSpan(
                  text: "${LanguageService.get("problem_description")}: ",
                  style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ticketData.ticketDetails?.problem ?? "No problem description available",
                  style: TextStyle(fontSize: 11, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          if (ticketData.ticketDetails?.media?.isEmpty ?? true) ...[
            SizedBox(),
          ] else ...[
            Text("Photos / Video", style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400)),

            SizedBox(height: 10),
            SizedBox(
              height: 75,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ticketData.ticketDetails!.media!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final media = ticketData.ticketDetails!.media![index];
                  return Container(
                    width: 103,
                    height: 75,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
                      color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                    ),
                    padding: EdgeInsets.all(10),
                    child: _buildMediaItemFromApi(context, media),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportFeeNoticeCard(BuildContext context, ReviewTicketViewModel model) {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageService.get('support_fee_notice'), style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Text(
            LanguageService.get('support_fee_notice_description'),
            style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primarySuperLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeeDetailRow("✅ ${LanguageService.get('support_type_onsite')}", AppColors.success),
                Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

                _buildFeeDetailRow("💲 ${LanguageService.get('fee_per_day')}", AppColors.black),
                Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

                _buildFeeDetailRow("📌 ${LanguageService.get('travel_note')}", AppColors.crimsonRed),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(LanguageService.get('review_and_proceed'), style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, ReviewTicketViewModel model) {
    final ticketData = model.ticketData;
    if (ticketData == null) return SizedBox.shrink();

    final cost = ticketData.pricingDetails?.cost ?? 0;
    final currency = ticketData.pricingDetails?.currency ?? "USD";
    final formattedCost = _formatCurrency(cost, currency);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppImages.payment, width: 20, height: 20, color: AppColors.primarySuperLight),
              SizedBox(width: 8),
              Text(LanguageService.get('payment'), style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LanguageService.get('total_payment'), style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(formattedCost, style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponCodeCard(BuildContext context, ReviewTicketViewModel model) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageService.get('coupon_code'), style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 16),
          CommonTextField(
            controller: model.couponController,
            placeholder: LanguageService.get('have_coupon_code'),
            suffixIcon: ElevatedButton(
              onPressed: model.applyCoupon,
              style: TextButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size(0, 32),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primary,
              ),
              child: Text(LanguageService.get('apply'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            contentPadding: EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
          ),
          if (model.appliedCoupon != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(model.appliedCoupon!, style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  GestureDetector(onTap: model.removeCoupon, child: Icon(Icons.close, color: AppColors.white, size: 16)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, ReviewTicketViewModel model) {
    final ticketData = model.ticketData;
    if (ticketData == null) return SizedBox.shrink();

    final cost = ticketData.pricingDetails?.cost ?? 0;
    final currency = ticketData.pricingDetails?.currency ?? "USD";
    final formattedCost = _formatCurrency(cost, currency);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedCost, style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(LanguageService.get('incl_taxes_fees'), style: TextStyle(color: AppColors.gray, fontSize: 12, fontWeight: FontWeight.w400)),
            ],
          ),
          Spacer(),
          ElevatedButton(
            onPressed: model.continueToPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v50)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(LanguageService.get('continue_to_pay'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeDetailRow(String text, Color iconColor) {
    return Text(text, style: TextStyle(color: AppColors.black, fontSize: 12, fontWeight: FontWeight.w500));
  }

  Widget _buildContactInfoRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Color _getWarrantyStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in warranty':
        return AppColors.success;
      case 'out of warranty':
        return AppColors.error;
      default:
        return AppColors.textPrimary;
    }
  }

  String _formatCurrency(int cost, String currency) {
    final symbol =
        currency == 'USD'
            ? '\$'
            : currency == 'INR'
            ? '₹'
            : currency;
    return '$symbol${cost.toStringAsFixed(2)}';
  }

  Widget _buildMediaItemFromApi(BuildContext context, Media media) {
    final isImage = media.type?.toLowerCase() == 'image';
    final imageUrl = 'https://triq.onrender.com${media.url}';

    return GestureDetector(
      onTap: () {
        if (isImage) {
          Navigator.pushNamed(context, Routes.imageViewerView, arguments: imageUrl);
        } else {
          Navigator.pushNamed(context, Routes.videoPlayer, arguments: imageUrl);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                    child: Icon(Icons.error_outline, color: AppColors.textGray, size: 20),
                  ),
            ),
            if (!isImage)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(child: Icon(Icons.play_circle_filled, color: Colors.white, size: 24)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.scaffoldBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerTicketDetailsCard(),
            SizedBox(height: 16),
            _buildShimmerSupportFeeNoticeCard(),
            Padding(padding: EdgeInsets.all(15), child: _buildShimmerPaymentCard()),
            Padding(padding: EdgeInsets.only(left: 15, right: 15, bottom: 15), child: _buildShimmerCouponCodeCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement retry functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTicketDetailsCard() {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(color: AppColors.lavenderMist, borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.all(16),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Text("US", style: const TextStyle(color: AppColors.colorBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, height: 16, width: 16)),
                  ),
                ],
              ),
              SizedBox(width: AppSizes.v10),

              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 20, width: 150, color: Colors.white),
                ),
              ),

              Container(height: 50, width: 1, color: AppColors.textGray.withValues(alpha: 0.1)),
              SizedBox(width: AppSizes.v10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 12, width: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 16, width: 120, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 12, width: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 16, width: 100, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 12, width: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 16, width: 90, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 12, width: 70, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 16, width: 80, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 12, width: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(height: 16, width: 80, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),

          RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
              children: [
                TextSpan(
                  text: "${LanguageService.get("problem_description")}: ",
                  style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
                ),
                WidgetSpan(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(height: 12, width: 200, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          Text("Photos / Video", style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400)),

          SizedBox(height: 10),

          SizedBox(
            height: 75,
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  width: 103,
                  height: 75,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.textGray.withValues(alpha: 0.1)),
                    color: AppColors.primarySuperLight.withValues(alpha: 0.1),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSupportFeeNoticeCard() {
    return Container(
      padding: EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 20, width: 150, color: Colors.white),
          ),
          SizedBox(height: 12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 16, width: double.infinity, color: Colors.white),
          ),
          SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 16, width: 250, color: Colors.white),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primarySuperLight.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 16, width: 200, color: Colors.white),
                ),
                SizedBox(height: 16),
                Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 16, width: 150, color: Colors.white),
                ),
                SizedBox(height: 16),
                Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(height: 16, width: 180, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 16, width: 120, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPaymentCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AppImages.payment, width: 20, height: 20, color: AppColors.primarySuperLight),
              SizedBox(width: 8),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(height: 20, width: 80, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(height: 16, width: 100, color: Colors.white),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(height: 20, width: 80, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCouponCodeCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(height: 20, width: 120, color: Colors.white),
          ),
          SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
