import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/services/language.service.dart';
import 'package:manager/services/ticket.service.dart';
import 'package:manager/core/models/review_ticket_model.dart';
import 'package:manager/core/locator.dart';

class ReviewTicketViewModel extends ReactiveViewModel {
  final TextEditingController couponController = TextEditingController();
  String? appliedCoupon;

  final TicketService _ticketService = locator<TicketService>();

  ReviewTicketModel? _ticketData;
  String? _ticketId;
  bool _isLoading = true;
  String? _errorMessage;

  ReviewTicketModel? get ticketData => _ticketData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void init({String? ticketId}) {
    _ticketId = ticketId ?? '';
    _loadTicketSummary();
  }

  Future<void> _loadTicketSummary() async {
    if (_ticketId == null) return;

    setBusy(true);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ticketService.getTicketSummary(ticketId: _ticketId!);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (data) {
        _ticketData = data;
        _isLoading = false;
        notifyListeners();
      },
    );

    setBusy(false);
  }

  void applyCoupon() {
    final couponCode = couponController.text.trim();
    if (couponCode.isNotEmpty) {
      appliedCoupon = couponCode;
      couponController.clear();
      notifyListeners();

      Fluttertoast.showToast(
        msg: LanguageService.get('coupon_applied_successfully'),
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      Fluttertoast.showToast(
        msg: LanguageService.get('please_enter_coupon_code'),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  void removeCoupon() {
    appliedCoupon = null;
    notifyListeners();

    Fluttertoast.showToast(
      msg: LanguageService.get('coupon_removed'),
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void continueToPay() {
    Fluttertoast.showToast(
      msg: LanguageService.get('redirecting_to_payment'),
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );

    // TODO: Implement actual payment navigation
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}
