import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  static List<String> categoryNames = [];
  static List<bool> categoryFlags = [];
  static List<Widget> categoryListView = [];

  /// Get AppInfo Stream to update UI after changes
  void _getAppInfoUpdates() {
    AppModel().getCategories(onSuccess: (Map<String, dynamic> categories) {
      categories.forEach((key, value) {
        categoryNames.add(key);
        categoryFlags.add(value);
      });
    });
  }

  void _toggleFlag(index) {
    setState(() {
      categoryFlags[index] = !categoryFlags[index];
    });
  }

  @override
  void initState() {
    super.initState();
    // Get updates
    _getAppInfoUpdates();
  }

  @override
  void dispose() {
    categoryListView.clear();
    categoryNames.clear();
    categoryFlags.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < categoryNames.length; i++) {
      categoryListView.add(Center(
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child:
                  Text(categoryNames[i], style: const TextStyle(fontSize: 18)),
              onPressed: () {
                AppModel().updateCategories(
                    key: categoryNames[i],
                    value: categoryFlags[i],
                    onSuccess: () {
                      _toggleFlag(i);
                    });
              },
            ),
          ),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: categoryListView,
        ),
      ),
    );
  }
}
