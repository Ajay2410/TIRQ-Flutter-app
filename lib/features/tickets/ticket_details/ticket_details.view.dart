import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manager/services/language.service.dart';
import 'package:stacked/stacked.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:manager/core/models/ticket_details_model.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/configs.dart';
import 'package:shimmer/shimmer.dart';
import 'ticket_details.vm.dart';

class TicketDetailsView extends StatelessWidget {
  final String? ticketId;

  const TicketDetailsView({super.key, this.ticketId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketDetailsViewModel>.reactive(
      viewModelBuilder: () => TicketDetailsViewModel(),
      onViewModelReady: (TicketDetailsViewModel model) => model.init(ticketId: ticketId),
      disposeViewModel: false,
      builder: (BuildContext context, TicketDetailsViewModel model, Widget? child) {
        return Scaffold(
          appBar: _buildAppBar(context, model),
          body: _buildBody(context, model),
          bottomNavigationBar: _buildBottomActionBar(context, model),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TicketDetailsViewModel model) {
    if (model.isLoading) {
      return _buildShimmerLoading();
    }

    if (model.hasError) {
      return _buildErrorState(context, model);
    }

    if (model.ticketDetails == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Container(
        color: AppColors.snowDrift,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerInfoCard(context, model),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildTicketDetailsCard(context, model),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildProblemDescriptionCard(context, model),
                  SizedBox(height: 16),
                  _buildMediaCard(context, model),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildWarrantyInfoCard(context, model),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(15), child: _buildPaymentCard(context, model)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.snowDrift,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppSizes.v10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerCustomerInfoCard(),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildShimmerTicketDetailsCard(),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildShimmerProblemDescriptionCard(),
                  SizedBox(height: 16),
                  _buildShimmerMediaCard(),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                  _buildShimmerWarrantyInfoCard(),
                  Divider(height: 26, color: AppColors.textGray.withValues(alpha: 0.1)),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(15), child: _buildShimmerPaymentCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TicketDetailsViewModel model) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.redBack),
            SizedBox(height: 16),
            Text('Error loading ticket details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text(
              model.errorMessage ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => model.refreshTicketDetails(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No ticket details found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text(
              'The ticket details could not be loaded',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, TicketDetailsViewModel model) {
    final pricingDetails = model.ticketDetails?.pricingDetails;
    final ticketDetails = model.ticketDetails?.ticketDetails;

    final totalCost = pricingDetails?.cost ?? 0;
    final currency = pricingDetails?.currency ?? 'USD';
    final paymentStatus = ticketDetails?.paymentStatus ?? 'unknown';
    final supportMode = pricingDetails?.supportMode ?? 'Unknown';
    final ticketType = pricingDetails?.ticketType ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(13),
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
                    Text(LanguageService.get('total_payment'), style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      model.formatCurrency(totalCost, currency),
                      style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Payment Status", style: TextStyle(color: AppColors.textGray, fontSize: 11, fontWeight: FontWeight.w500)),
                    Text(
                      paymentStatus.toUpperCase(),
                      style: TextStyle(
                        color: paymentStatus.toLowerCase() == 'paid' ? AppColors.color41C293 : AppColors.crimsonRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Support Mode",
                      style: TextStyle(color: AppColors.textGray, fontSize: 11, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    Text(supportMode, style: TextStyle(color: AppColors.textGray, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
                Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ticket Type",
                      style: TextStyle(color: AppColors.textGray, fontSize: 11, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    Text(ticketType, style: TextStyle(color: AppColors.textGray, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 0, color: AppColors.textGray.withValues(alpha: 0.1)),
          Row(
            children: [
              SizedBox(width: 13),
              Expanded(child: Text("Get Tax Invoice", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
              IconButton(
                onPressed: () {
                  // TODO: Implement tax invoice functionality
                },
                icon: Transform.rotate(angle: math.pi, child: Image.asset(AppImages.back, height: 22, width: 22)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TicketDetailsViewModel model) {
    final ticketNumber = model.ticketDetails?.ticketDetails?.ticketNumber ?? '#Loading...';
    final status = model.ticketDetails?.ticketDetails?.status ?? 'Loading...';

    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      title: Text(ticketNumber, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
      actions: [
        SizedBox(
          height: 25,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.white,
              padding: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
            ),
            onPressed: () {},
            child: Text(model.getStatusColor(status), style: TextStyle(color: AppColors.primary, fontSize: 10)),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(BuildContext context, TicketDetailsViewModel model) {
    final orgDetails = model.ticketDetails?.processorDetails;
    final ticketDetails = model.ticketDetails?.ticketDetails;
    final config = locator<Configurations>();

    final customerName = orgDetails?.fullName ?? 'Unknown Customer';
    final flag = orgDetails?.flag?.startsWith('/') == true ? orgDetails!.flag!.substring(1) : orgDetails?.flag ?? 'flags/us.svg';
    final flagUrl = '${config.baseUrl}$flag';
    final supportType = ticketDetails?.ticketType ?? 'Unknown';
    final createdAt = ticketDetails?.createdAt;

    // Calculate days since creation
    String pendingText = 'Loading...';
    if (createdAt != null) {
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      pendingText = 'Pending Since: ${days} Days ${hours} hours';
    }

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.lavenderMist, borderRadius: BorderRadius.circular(14)),
              padding: EdgeInsets.all(16),
              child: Text(
                customerName.substring(0, 2).toUpperCase(),
                style: const TextStyle(color: AppColors.colorBlue, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SvgPicture.network(
                  flagUrl,
                  height: 16,
                  width: 16,
                  placeholderBuilder: (context) => Container(height: 16, width: 16, color: AppColors.textGray),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.ticketDetails?.ticketDetails?.ticketType ?? "",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              SizedBox(height: 4),
              Text(pendingText, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(height: 50, width: 1, color: AppColors.textGray.withValues(alpha: 0.1)),
        SizedBox(width: AppSizes.v10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Support Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
            const SizedBox(height: 4),
            Text(supportType, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketDetailsCard(BuildContext context, TicketDetailsViewModel model) {
    final ticketDetails = model.ticketDetails?.ticketDetails;
    final machineDetails = model.ticketDetails?.machineDetails;
    final customerMachineDetails = model.ticketDetails?.customerMachineDetails;

    final createdDate = ticketDetails?.createdAt != null ? model.formatDate(ticketDetails!.createdAt) : 'N/A';
    final errorCode = ticketDetails?.errorCode ?? 'N/A';
    final warrantyStatus = customerMachineDetails?.warrantyStatus ?? 'Unknown';
    final machineName = machineDetails?.machineName ?? 'Unknown';
    final modelNumber = machineDetails?.modelNumber ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ticket Details", style: TextStyle(color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDetailItem("Created Date", createdDate)),
            Expanded(child: _buildDetailItem("Error Code", errorCode)),
            Expanded(
              child: _buildDetailItem(
                "Warranty Status",
                model.getWarrantyStatusColor(warrantyStatus),
                valueColor: warrantyStatus.toLowerCase() == 'in warranty' ? AppColors.color41C293 : AppColors.crimsonRed,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDetailItem("Machine Name", machineName)),
            Expanded(child: _buildDetailItem("Model Number", modelNumber)),
            Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildProblemDescriptionCard(BuildContext context, TicketDetailsViewModel model) {
    final problem = model.ticketDetails?.ticketDetails?.problem ?? 'No problem description available';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
            children: [
              TextSpan(
                text: "${LanguageService.get("problem_description")}: ",
                style: TextStyle(fontSize: 11, color: AppColors.black, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: problem, style: TextStyle(fontSize: 11, color: AppColors.textGray)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaCard(BuildContext context, TicketDetailsViewModel model) {
    final mediaList = model.ticketDetails?.ticketDetails?.media ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaList.isEmpty) ...[
          SizedBox(),
        ] else ...[
          Text("Photos / Video", style: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w400)),
          SizedBox(height: 10),

          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final media = mediaList[index];
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
    );
  }

  Widget _buildWarrantyInfoCard(BuildContext context, TicketDetailsViewModel model) {
    final customerMachineDetails = model.ticketDetails?.customerMachineDetails;

    final purchaseDate = customerMachineDetails?.purchaseDate != null ? model.formatDate(customerMachineDetails!.purchaseDate) : 'N/A';
    final installationDate = customerMachineDetails?.installationDate != null ? model.formatDate(customerMachineDetails!.installationDate) : 'N/A';
    final warrantyStart = customerMachineDetails?.warrantyStart != null ? model.formatDate(customerMachineDetails!.warrantyStart) : 'N/A';
    final warrantyEnd = customerMachineDetails?.warrantyEnd != null ? model.formatDate(customerMachineDetails!.warrantyEnd) : 'N/A';
    final warrantyStatus = customerMachineDetails?.warrantyStatus ?? 'Unknown';
    final invoiceContractNo = customerMachineDetails?.invoiceContractNo ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInfoRow(AppImages.purchaseDate, 'purchase_date'.lang, purchaseDate, AppColors.colorF2A22E)),
            SizedBox(width: 14),
            Expanded(child: _buildInfoRow(AppImages.installationDate, 'installation_date'.lang, installationDate, AppColors.colorFF6868)),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildInfoRow(AppImages.warrantyDate, 'warranty_start'.lang, warrantyStart, AppColors.primarySuperLight)),
            SizedBox(width: 14),
            Expanded(child: _buildInfoRow(AppImages.warrantyDate, 'warranty_end'.lang, warrantyEnd, AppColors.primarySuperLight, isWarning: true)),
          ],
        ),
        const SizedBox(height: 10),
        Divider(color: AppColors.lightGray),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                AppImages.warrantyStatus,
                'warranty_status'.lang,
                model.getWarrantyStatusColor(warrantyStatus),
                AppColors.color41C293,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildInfoRow(AppImages.invoice, 'invoice_contract_no'.lang, invoiceContractNo, AppColors.color41C293)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String iconPath, String label, String value, Color iconColor, {bool isWarning = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: isWarning ? AppColors.redBack : AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
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

  Widget _buildBottomActionBar(BuildContext context, TicketDetailsViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: model.startChat,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.v50)),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text("See Chat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // Shimmer loading methods
  Widget _buildShimmerCustomerInfoCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14))),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 18, width: 150, color: AppColors.white),
                SizedBox(height: 4),
                Container(height: 14, width: 120, color: AppColors.white),
              ],
            ),
          ),
          Container(height: 50, width: 1, color: AppColors.textGray.withValues(alpha: 0.1)),
          SizedBox(width: AppSizes.v10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(height: 12, width: 80, color: AppColors.white),
              SizedBox(height: 4),
              Container(height: 14, width: 60, color: AppColors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerTicketDetailsCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 120, color: AppColors.white),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: _buildShimmerDetailItem()),
              SizedBox(width: 16),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDetailItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 12, width: 80, color: AppColors.white),
        SizedBox(height: 4),
        Container(height: 14, width: 60, color: AppColors.white),
      ],
    );
  }

  Widget _buildShimmerProblemDescriptionCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 16, width: 150, color: AppColors.white),
          SizedBox(height: 8),
          Container(height: 14, width: double.infinity, color: AppColors.white),
          SizedBox(height: 4),
          Container(height: 14, width: 200, color: AppColors.white),
        ],
      ),
    );
  }

  Widget _buildShimmerMediaCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 14, width: 100, color: AppColors.white),
          SizedBox(height: 10),
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  width: 103,
                  height: 75,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), color: AppColors.white),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerWarrantyInfoCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
          SizedBox(height: 10),
          Divider(color: AppColors.lightGray),
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 14), Expanded(child: _buildShimmerInfoRow())]),
          SizedBox(height: 10),
          Divider(color: AppColors.lightGray),
          SizedBox(height: 10),
          Row(children: [Expanded(child: _buildShimmerInfoRow()), SizedBox(width: 16), Expanded(child: _buildShimmerInfoRow())]),
        ],
      ),
    );
  }

  Widget _buildShimmerInfoRow() {
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8))),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 12, width: 80, color: AppColors.white),
              SizedBox(height: 4),
              Container(height: 14, width: 60, color: AppColors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerPaymentCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.textGray.withValues(alpha: 0.1),
      highlightColor: AppColors.textGray.withValues(alpha: 0.3),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 20, height: 20, color: AppColors.white),
                      SizedBox(width: 8),
                      Container(height: 16, width: 80, color: AppColors.white),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 14, width: 100, color: AppColors.white), Container(height: 16, width: 80, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                  SizedBox(height: 24),
                  Divider(height: 24, color: AppColors.textGray.withValues(alpha: 0.1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Container(height: 11, width: 80, color: AppColors.white), Container(height: 11, width: 60, color: AppColors.white)],
                  ),
                ],
              ),
            ),
            Divider(height: 0, color: AppColors.textGray.withValues(alpha: 0.1)),
            Row(
              children: [
                SizedBox(width: 13),
                Expanded(child: Container(height: 12, width: 100, color: AppColors.white)),
                Container(width: 22, height: 22, color: AppColors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
