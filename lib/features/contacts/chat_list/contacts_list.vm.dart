import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager/features/Messages/chat/chat.view.dart';
import 'package:manager/services/chat.service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';
import '../../../core/models/employee.dart';
import '../../../core/utils/app_logger.dart';
import '../../../resources/app_resources/app_resources.dart';
import '../../../routes/routes.dart';
import '../../../services/employee.service.dart';

class ContactsListViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _chatService = locator<ChatService>();
  final _employeeService = locator<EmployeeService>();

  // External chat rooms
  List<ChatViewAttributes> _externalChatRooms = [];
  List<ChatViewAttributes> get externalChatRooms => _filteredExternalChatRooms.isNotEmpty ? _filteredExternalChatRooms : _externalChatRooms;

  List<Employee> _employees = [];
  List <Employee> get employees =>  _employees;

  // Archived chat rooms
  List<ChatViewAttributes> _archivedChatRooms = [];
  List<ChatViewAttributes> get archivedChatRooms => _archivedChatRooms;

  List<ChatViewAttributes> _filteredExternalChatRooms = [];
  List<Employee> _filteredEmployees = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';

  StreamSubscription? _refreshSubscription;

  void init() async {
    _isLoading = true;
    notifyListeners();

    // Load both employees and external chats
    await Future.wait([
      _loadEmployees(),
      _loadExternalChats(),
    ]);

    _isLoading = false;
    notifyListeners();

    // Listen to refresh triggers from the service
    _refreshSubscription = _chatService.refreshStream.listen((trigger) {
      if (trigger && !_chatService.isRefreshing) {
        AppLogger.highlight("Received refresh trigger, refreshing contacts list");
        _refreshAll();
      }
    });
  }

  Future<void> _loadEmployees() async {
    try {
      final result = await _employeeService.getAllEmployees();

      result.fold(
            (failure) {
          AppLogger.error('Failed to get employees: ${failure.message}');
          _employees = [];
        },
            (response) {
          _employees = response;
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching employees: $e');
      _employees = [];
    }
  }

  Future<void> _loadExternalChats() async {
    try {
      final result = await _chatService.getExternalChatRooms();

      result.fold(
            (failure) {
          AppLogger.error('Failed to get external chat rooms: ${failure.message}');
          _externalChatRooms = [];
        },
            (response) {
          _externalChatRooms = response;
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching external chat rooms: $e');
      _externalChatRooms = [];
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadEmployees(),
      _loadExternalChats(),
    ]);

    // Reapply search filter if there's an active search
    if (_searchQuery.isNotEmpty) {
      _applySearchFilter();
    }

    notifyListeners();
  }

  Future<void> refreshEmployees() async {
    await _loadEmployees();
    if (_searchQuery.isNotEmpty) {
      _applySearchFilter();
    }
    notifyListeners();
  }

  Future<void> refreshExternalChats() async {
    await _loadExternalChats();
    if (_searchQuery.isNotEmpty) {
      _applySearchFilter();
    }
    notifyListeners();
  }

  Future<void> createIndividualChat(Employee employee) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _chatService.createIndividualChatRoom(
        employeeIds: [ employee.id ?? ""],
      );

      result.fold(
            (failure) {
          AppLogger.error('Failed to create individual chat: ${failure.message}');

          Fluttertoast.showToast(
            msg: "Failed to create chat",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (chatResponse) {
          // Navigate to chat with the response data
          _navigationService.navigateTo(
            Routes.chat,
            arguments: chatResponse,
          );
        },
      );
    } catch (e) {
      AppLogger.error('Error creating individual chat: $e');

      Fluttertoast.showToast(
        msg: "Error creating chat",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToChat(ChatViewAttributes chatRoom) async {
    await _navigationService.navigateTo(
      Routes.chat,
      arguments: chatRoom,
    );
    // Refresh data when returning from chat
    init();
  }

  void navigateToArchivedChats() {
    _navigationService.navigateTo(
      Routes.archivedChats,
    );
  }

  Future<void> loadArchivedChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _chatService.getArchivedChatRooms();

      result.fold(
            (failure) {
          AppLogger.error('Failed to get archived chat rooms: ${failure.message}');
          _archivedChatRooms = [];

          Fluttertoast.showToast(
            msg: "Failed to load archived chats",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
          );
        },
            (response) {
          _archivedChatRooms = response;
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching archived chat rooms: $e');
      _archivedChatRooms = [];

      Fluttertoast.showToast(
        msg: "Error loading archived chats",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterContacts(String query) {
    _searchQuery = query.toLowerCase();
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredEmployees = [];
      _filteredExternalChatRooms = [];
      return;
    }

    // Filter employees
    _filteredEmployees = _employees.where((employee) {
      final name = _getEmployeeName(employee).toLowerCase();
      final designation = _getEmployeeDesignation(employee).toLowerCase();
      return name.contains(_searchQuery) || designation.contains(_searchQuery);
    }).toList();

    // Filter external chats
    _filteredExternalChatRooms = _externalChatRooms.where((chatRoom) {
      final title = _getChatTitle(chatRoom).toLowerCase();
      return title.contains(_searchQuery);
    }).toList();
  }

  // Helper methods for filtering
  String _getEmployeeName(Employee employee) {
    return employee.fullName ?? "Unknown Employee";
  }

  String _getEmployeeDesignation(Employee employee) {
    return employee.role ?? "";
  }

  String _getChatTitle(ChatViewAttributes chatRoom) {
    if (chatRoom.organization?.name?.isNotEmpty == true) {
      return chatRoom.organization!.name!;
    } else if (chatRoom.ticket?.ticketId != null) {
      return chatRoom.ticket!.ticketId!;
    } else {
      return "Chat #${chatRoom.id.substring(0, 6)}";
    }
  }

  @override
  void dispose() {
    // Clean up the subscription when the view model is disposed
    _refreshSubscription?.cancel();
    super.dispose();
  }
}