import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class FoodCategory extends StatefulWidget {
  const FoodCategory({Key? key}) : super(key: key);

  @override
  _FoodCategoryState createState() => _FoodCategoryState();
}

class _FoodCategoryState extends State<FoodCategory> {
  static List<Map<String, dynamic>> categories = [];

  final _nameController = TextEditingController();

  void _getFoodCategory() {
    AppModel().getFoodCategories(
      onSuccess: (List<Map<String, dynamic>> param) {
        categories = param;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    _getFoodCategory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listView = [];

    List<Widget> editView = [];
    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  hintText: "Enter food category name.",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (name) {
                  if (name?.isEmpty ?? true) {
                    return "Please enter a food category name.";
                  }
                  return null;
                },
              ))),
    ));
    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child:
                  const Text("Add a category", style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_nameController.text.trim() == '') return;
                AppModel().setFoodCategories(
                    name: _nameController.text.trim(),
                    onSuccess: () {
                      _nameController.text = '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getFoodCategory();
                    });
              },
            ),
          )),
    ));

    List<Widget> categoryView = [];
    for (var i = 0; i < categories.length; i++) {
      categoryView.add(Center(
        child: SizedBox(
          width: 350,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(categories[i][CATEGORY_NAME]),
          ),
        ),
      ));
    }

    listView = [...editView, ...categoryView];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Categories"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: listView,
        ),
      ),
    );
  }
}
