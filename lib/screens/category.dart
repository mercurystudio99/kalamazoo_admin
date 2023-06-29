import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class Category extends StatefulWidget {
  const Category({Key? key}) : super(key: key);

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  static Map<String, dynamic> categories = {};
  static List<Widget> categoryListView = [];

  /// Get AppInfo Stream to update UI after changes
  void _getAppInfoUpdates() {
    AppModel().getCategories(onSuccess: (Map<String, dynamic> result) {
      categories = result;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    categories.forEach((key, value) {
      categoryListView.add(Center(
        child: SizedBox(
          width: 300,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child: Text(key, style: const TextStyle(fontSize: 18)),
              onPressed: () {
                AppModel()
                    .updateCategories(key: key, value: value, onSuccess: () {});
              },
            ),
          ),
        ),
      ));
    });

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
