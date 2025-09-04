import 'package:flutter/material.dart';
import 'package:manager/features/tasks/tasks_home/tasks_home.vm.dart';
import 'package:stacked/stacked.dart';

import '../../../resources/app_resources/app_resources.dart';

class TasksHomeView extends StatefulWidget {
  const TasksHomeView({super.key});

  @override
  State<TasksHomeView> createState() => _TasksHomeViewState();
}

class _TasksHomeViewState extends State<TasksHomeView>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TasksHomeViewModel>.reactive(
      viewModelBuilder: () => TasksHomeViewModel(),
      onViewModelReady: (TasksHomeViewModel model) => model.init(this),
      disposeViewModel: false,
      builder: (BuildContext context, TasksHomeViewModel model, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: RichText(
              text: TextSpan(
                text: "Manage ",
                style: Theme.of(context).textTheme.displayMedium,
                children: [
                  TextSpan(
                    text: "Tasks",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.person))],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: ElevatedButton(
            onPressed: () {},
            style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              maximumSize: WidgetStatePropertyAll(
                Size(AppSizes.w170, AppSizes.h70),
              ),
              shadowColor: WidgetStatePropertyAll(AppColors.gray),
              elevation: WidgetStatePropertyAll(AppSizes.v6),
            ),
            child: Row(
              spacing: AppSizes.w8,
              children: [
                Icon(Icons.add),
                Text(
                  'Assign Task',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.w20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.h20),
                  child: SearchBar(
                    leading: Icon(Icons.search, color: AppColors.gray),
                    hintText: 'Search for tasks',
                  ),
                ),
                TabBar(
                  controller: model.tabController,
                  tabs: [
                    Tab(text: 'Completed Tasks'),
                    Tab(text: 'Pending Tasks'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: model.tabController,
                    children: [
                      ListView.builder(
                        itemCount: 10,
                        padding: EdgeInsets.only(
                          bottom: 2 * kBottomNavigationBarHeight,
                        ),
                        itemBuilder: (context, index) {
                          return _buildExpandableTile(
                            model.expandedCompletedTileIndex,
                            index,
                            model.expandCompletedTile,
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: 10,
                        padding: EdgeInsets.only(
                          bottom: 2 * kBottomNavigationBarHeight,
                        ),
                        itemBuilder: (context, index) {
                          return _buildExpandableTile(
                            model.expandedPendingTileIndex,
                            index,
                            model.expandPendingTile,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableTile(
    int? expandedIndex,
    int index,
    Function(int) onTap,
  ) {
    bool isExpanded = index == expandedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.v14),
          border: Border(
            left: BorderSide(color: AppColors.primary, width: AppSizes.w4),
          ),
          color: AppColors.scaffoldBackground,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 3,
            ),
          ],
        ),
        margin:
            EdgeInsets.only(top: AppSizes.h10) +
            EdgeInsets.symmetric(horizontal: AppSizes.w4),
        child: Column(
          children: [
            ListTile(
              title: Text(
                "#Tasks No. ${index + 1}",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.gray,
              ),
            ),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  isExpanded
                      ? Container(
                        padding: EdgeInsets.all(16),
                        child: Text("Details for Tasks No. ${index + 1}"),
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
