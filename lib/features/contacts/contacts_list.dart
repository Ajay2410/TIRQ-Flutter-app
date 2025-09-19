import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/common_app_bar.dart';

class ContactsListView extends StatefulWidget {
  const ContactsListView({super.key});

  @override
  State<ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<ContactsListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: GradientAppBar(
        title: 'Contacts',
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.white, size: 24),
            onPressed: () {
              // Handle search
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppColors.white, size: 24),
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Contacts List',
          style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
