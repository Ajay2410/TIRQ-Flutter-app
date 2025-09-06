import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'machine_supplier_details/machine_supplier_details.view.dart';

// Dummy data models
class DummyMachine {
  final String id;
  final String machineName;
  final String? notes;
  final String? organizationName;

  DummyMachine({
    required this.id,
    required this.machineName,
    this.notes,
    this.organizationName,
  });
}

class DummyOrganization {
  final String id;
  final String fullName;

  DummyOrganization({required this.id, required this.fullName});
}

class MachineSupplierViewModel extends BaseViewModel {
  List<DummyMachine> _machines = [];
  List<DummyMachine> _filteredMachines = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<DummyMachine> get machines => _machines;
  List<DummyMachine> get filteredMachines => _filteredMachines;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  @override
  bool get hasError => _hasError;

  String get errorMessage => _errorMessage;

  void init() {
    _searchQuery = '';
    _loadMachines();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  Future<void> _loadMachines() async {
    _setLoading(true);
    _hasError = false;
    _errorMessage = '';

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // Dummy data
      _machines = [
        DummyMachine(
          id: '1',
          machineName: 'Industrial Press Machine',
          notes: 'High-performance hydraulic press for metal forming',
          organizationName: 'TechCorp Industries',
        ),
        DummyMachine(
          id: '2',
          machineName: 'CNC Milling Center',
          notes: 'Precision machining center with 5-axis capability',
          organizationName: 'Precision Manufacturing Ltd',
        ),
        DummyMachine(
          id: '3',
          machineName: 'Laser Cutting System',
          notes: 'Fiber laser cutting machine for sheet metal',
          organizationName: 'LaserTech Solutions',
        ),
        DummyMachine(
          id: '4',
          machineName: 'Robotic Assembly Line',
          notes: 'Automated assembly system with 6-axis robots',
          organizationName: 'AutoBot Systems',
        ),
        DummyMachine(
          id: '5',
          machineName: 'Quality Control Station',
          notes: 'Automated inspection and testing equipment',
          organizationName: 'QualityFirst Corp',
        ),
        DummyMachine(
          id: '6',
          machineName: 'Packaging Machine',
          notes: 'High-speed packaging and labeling system',
          organizationName: 'PackPro Industries',
        ),
        DummyMachine(
          id: '7',
          machineName: 'Welding Station',
          notes: 'Automated welding system with vision guidance',
          organizationName: 'WeldMaster Ltd',
        ),
        DummyMachine(
          id: '8',
          machineName: 'Surface Treatment Unit',
          notes: 'Coating and surface finishing equipment',
          organizationName: 'SurfaceTech Inc',
        ),
      ];

      _filteredMachines = _machines;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> refreshMachines() async {
    await _loadMachines();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredMachines =
        _machines.where((machine) {
          bool matchesSearch =
              _searchQuery.isEmpty ||
              machine.machineName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (machine.organizationName?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);

          return matchesSearch;
        }).toList();

    notifyListeners();
  }

  DummyOrganization? getOrganizationForMachine(DummyMachine machine) {
    if (machine.organizationName != null) {
      return DummyOrganization(
        id: machine.id,
        fullName: machine.organizationName!,
      );
    }
    return null;
  }

  void onMachineTap(BuildContext context, DummyMachine machine) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MachineSupplierDetailsView(),
      ),
    );
  }
}
