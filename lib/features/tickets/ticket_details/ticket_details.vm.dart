import 'package:stacked/stacked.dart';
import 'package:manager/core/locator.dart';
import 'package:manager/core/models/ticket_details_model.dart';
import 'package:manager/services/ticket.service.dart';

class TicketDetailsViewModel extends BaseViewModel {
  final TicketService _ticketService = locator<TicketService>();

  TicketDetailsModel? _ticketDetails;
  String? _errorMessage;
  String? _ticketId;

  // Getters
  TicketDetailsModel? get ticketDetails => _ticketDetails;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isLoading => isBusy;

  // Initialize the view model with ticket ID
  void init({String? ticketId}) {
    _ticketId = ticketId;
    if (ticketId != null) {
      fetchTicketDetails();
    }
  }

  // Fetch ticket details from API
  Future<void> fetchTicketDetails() async {
    if (_ticketId == null) return;

    setBusy(true);
    _errorMessage = null;
    notifyListeners();

    final result = await _ticketService.getTicketDetails(ticketId: _ticketId!);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        setBusy(false);
        notifyListeners();
      },
      (ticketDetails) {
        _ticketDetails = ticketDetails;
        _errorMessage = null;
        setBusy(false);
        notifyListeners();
      },
    );
  }

  // Refresh ticket details
  Future<void> refreshTicketDetails() async {
    await fetchTicketDetails();
  }

  // Start chat functionality
  void startChat() {
    // TODO: Implement chat functionality
    // This could navigate to a chat screen or open a chat dialog
  }

  // Get formatted date string
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;

    return '$month $day, $year';
  }

  // Get formatted currency string
  String formatCurrency(int? amount, String? currency) {
    if (amount == null) return 'N/A';
    final currencySymbol = currency == 'USD' ? '\$' : '₹';
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  // Get status color
  String getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'resolved':
        return 'Resolved';
      case 'onhold':
        return 'On Hold';
      default:
        return status ?? 'Unknown';
    }
  }

  // Get warranty status color
  String getWarrantyStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'in warranty':
        return 'In Warranty';
      case 'out of warranty':
        return 'Out of Warranty';
      case 'expired':
        return 'Expired';
      default:
        return status ?? 'Unknown';
    }
  }
}
