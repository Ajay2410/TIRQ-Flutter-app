/// **ApiEndpoints**
///
/// This abstract class defines the API endpoint constants used throughout the app.
/// Centralizing API endpoints in a single class ensures maintainability and avoids hardcoded strings.
///
/// ### **Usage Example:**
/// ```dart
/// final response = await apiClient.get(ApiEndpoints.user);
/// ```
///
/// ### **Available Endpoints:**
/// - **`user`** → `user` (Endpoint for user-related operations)
abstract class ApiEndpoints {
  /// Base endpoint for user-related operations.
  static const String register = 'auth/register';
  static const String verifyEmail = 'auth/verify-email';
  static const String verifyPhone = 'auth/verify-phone';
  static const String forgotPassword = 'auth/forgot-password';
  static const String sendOtp = 'auth/send-otp';
  static const String otpLogin = 'auth/otp-login';
  static const String resetPassword = 'auth/reset-password';
  static const String googleLogin = 'auth/google-login';
  static const String facebookLogin = 'auth/facebook-login';
  static const String logout = 'auth/logout';

  static const String addPartner = 'org/add-partner';
  static const String addNewPartner = 'org/add-new';
  static const String addManufacturer = 'org/add-manufacturer';
  static const String getPartners = 'org/partnerships';
  static const String getEmployees = 'employee/org';
  static const String employee = 'employee';
  // static const String allEmployee = 'employee/get-all';

  static const String addNewEmployee = 'employee/add-new';
  static const String login = 'auth/login';
  static const String acceptRequest = 'org/accept-partner';
  static const String declineRequest = 'org/reject-partner';
  static const String machine = 'machines';
  static const String createMachine = 'machines/create';
  static const String assignMachine = 'machine/assign-machine';

  static const String getChatId = 'chat/room-create';
  static const String sendMessage = 'chat/room';
  static const String archiveChatRoom = 'chat/rooms-archive';
  static const String getAllChats = 'chat/getAllChats';
  static const String getAllChatMessages = 'chat/messages';
  static const String uploadChatFile = 'chat/upload/chat';
  // static const String chatRooms = 'chat/rooms';
  // static const String externalChatRooms = 'auth/rooms-external';
  static const String createIndividualChatRoom = 'chat/room-create-individual';

  static const String getMyMachines = 'machine/my-machines';
  static const String org = 'org/partner-by-id';
  static const String dashboard = 'dashboard';
  static const String tickets = 'ticket';
  static const String pingTicket = 'ticket/ping';
  static const String holdTicket = 'ticket/status';
  static const String uploadImages = 'upload/images';
  // static const String profile = 'auth/profile';

  // static const String updateFcmToken = 'auth/update-fcm-token';
  static const String resolveTicket = 'ticket/resolve';
  static const String requestResolveTicket = 'ticket/resolve-request';
  static const String rejectResolveTicket = 'ticket/forbid-resolve-request';
  static const String removeProcessor = 'org/remove';

  static const String getCustomers = 'customers/get-customers';
  static const String getCustomerById = 'customers/getCustomerById';
  static const String createCustomer = 'customers/create-customer';
  static const String updateCustomer = 'customers/update-customer';
  static const String deleteCustomer = 'customers/delete-customer';
  static const String searchCustomers = 'customers/search-customers';
  static const String removeMachine = 'customers/remove-machine';
  static const String getAllMachines = 'machines/getAll';
  static const String deleteMachine = 'machines/delete';
  static const String getMachineSupplier = 'machinesupplier/getMachineSupplier';
  static const String getMachineOverview = 'machinesupplier/getMachineOverview';
  static const String getMachineById = 'machines/getById';
  static const String createTicket = 'ticket/create';
  static const String updateTicket = 'ticket/update';
  static const String getAllTickets = 'ticket/getAll';
  static const String getTicketsByStatus = 'ticket/getticket';
  static const String getTicketSummary = 'ticket/getTicketSummary';

  // Service Pricing endpoints
  static const String createServicePricing = 'servicePricing/create';
  static const String getAllServicePricing = 'servicePricing/getAll';
}
