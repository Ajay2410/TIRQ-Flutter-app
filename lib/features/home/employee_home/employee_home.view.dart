import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'employee_home.vm.dart';

class EmployeeHomeView extends StatelessWidget {
  const EmployeeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<EmployeeHomeViewModel>.reactive(
      viewModelBuilder: () => EmployeeHomeViewModel(),
      onViewModelReady: (EmployeeHomeViewModel model) => model.init(),
      disposeViewModel: false,
      builder: (
        BuildContext context,
        EmployeeHomeViewModel model,
        Widget? child,
      ) {
        return Placeholder();
      },
    );
  }
}
