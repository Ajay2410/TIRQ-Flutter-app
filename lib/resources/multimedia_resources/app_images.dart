part of 'resources.dart';

abstract class AppImages {
  static const String apple = "assets/images/apple.svg";
  static const String linkedin = "assets/images/linkedin.svg";
  static const String google = "assets/images/google.svg";
  static const String facebook = "assets/images/facebook.svg";
  static const String wechat = "assets/images/wechat.svg";
  static const String microsoft = "assets/images/microsoft.svg";
  static const String cornerCircle = "assets/images/corner-circle.svg";
  static const String back = "assets/images/back.png";

  static const String contactBookActive =
      "assets/images/contact-book-active1.png";
  static const String contactBookInactive =
      "assets/images/contact-book-inactive1.png";

  static const String conversationActive =
      "assets/images/conversation-active1.png";
  static const String conversationInactive =
      "assets/images/conversation-inactive1.png";

  static const String homeActive = "assets/images/home-active1.png";
  static const String homeInactive = "assets/images/home-inactive1.png";

  static const String ticketActive = "assets/images/ticket-active1.png";
  static const String ticketInactive = "assets/images/ticket-inactive1.png";

  static const String userActive = "assets/images/user-active1.png";
  static const String userInactive = "assets/images/user-inactive1.png";

  static const String triqLogo = "assets/images/triq_logo.png";
  static const String triqLogo2 = "assets/images/logo2.png";
  static const String triqLogo3 = "assets/images/logo3.png";

  // Organization Images
  static const String organization = "assets/icons/organization.png";

  // Dashboard Icons
  static const String ticketSummary = "assets/icons/ticket_summary.png";
  static const String myCustomers = "assets/icons/my_customers.png";
  static const String myTeam = "assets/icons/my_team.png";
  static const String tasks = "assets/icons/tasks.png";
  static const String machineSuppliers = "assets/icons/machine_suppliers.png";
  static const String glassFlowSystem = "assets/icons/glass_flow_system.png";
  static const String piInvoice = "assets/icons/pi_invoice.png";
  static const String analyticsDashboard =
      "assets/icons/analytics_dashboard.png";
  static const String machineRecords = "assets/icons/machine_records.png";
  static const String feedbackRating = "assets/icons/feedback_rating.png";
  static const String installationTracker =
      "assets/icons/installation_tracker.png";
  static const String feedbackSurvey = "assets/icons/feedback_survay.png";

  // My Customers Screen Icons
  static const String search = "assets/icons/search.png";
  static const String filter = "assets/icons/filter.png";
  static const String add = "assets/icons/add.png";
  static const String check = "assets/icons/check.png";
  static const String egyptFlag = "assets/icons/filter.png";
  static const String arrowRight = "assets/icons/arrow_right.png";
  static const String refresh = "assets/icons/refresh.png";

  // Common Icons
  static const String warning = "assets/icons/warning.png";
  static const String alert = "assets/icons/alert.png";

  // Machine Details Icons
  static const String modelNumber = "assets/icons/model_number.png";
  static const String machineType = "assets/icons/machine_type.png";
  static const String height = "assets/icons/height.png";
  static const String width = "assets/icons/width.png";
  static const String thickness = "assets/icons/thickness.png";
  static const String maxSpeed = "assets/icons/max_speed.png";
  static const String powerConsumption = "assets/icons/power_consumption.png";
  static const String purchaseDate = "assets/icons/purchase_date.png";
  static const String installationDate = "assets/icons/installation_date.png";
  static const String warrantyDate = "assets/icons/warranty_date.png";
  static const String warrantyStatus = "assets/icons/warranty_status.png";
  static const String invoice = "assets/icons/invoice.png";

  // Add New Customer Icons
  static const String camera = "assets/icons/camera.png";
  static const String phone = "assets/icons/phone.png";
  static const String addCircle = "assets/icons/add_circle.png";

  // Search Screen Icons
  static const String earthSearch = "assets/images/earth_search.png";
  static const String flag = "assets/images/flag.png";

  // Flag URL construction
  static String getFlagUrl(String flagPath) {
    if (flagPath.startsWith('http')) {
      return flagPath;
    }
    final config = locator<Configurations>();

    String baseUrl = config.baseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return '$baseUrl$flagPath';
  }

  // SVG Flag widget for network loading
  static Widget getSvgFlag(
    String flagPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return SvgPicture.network(
      getFlagUrl(flagPath),
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder:
          (context) =>
              Image.asset(flag, width: width, height: height, fit: fit),
      errorBuilder:
          (context, error, stackTrace) =>
              Image.asset(flag, width: width, height: height, fit: fit),
    );
  }
}
