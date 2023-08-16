import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class FoodEdit extends StatefulWidget {
  // Variables
  final String id;

  const FoodEdit({Key? key, required this.id}) : super(key: key);

  @override
  _FoodEditState createState() => _FoodEditState();
}

class _FoodEditState extends State<FoodEdit> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  Map<String, dynamic> info = {};
  static List<Map<String, dynamic>> categories = [];
  static List<String> listCategory = <String>['None'];
  String category = '';

  void _getFoodByID() {
    AppModel().getFood(
        id: widget.id,
        onSuccess: (param) {
          info = param!;
          _nameController.text = info[MENU_NAME];
          _priceController.text = info[MENU_PRICE] ?? '';
          _descriptionController.text = info[MENU_DESCRIPTION] ?? '';
          if (info[MENU_CATEGORY] != null ||
              info[MENU_CATEGORY].toString().isNotEmpty) {
            for (var i = 0; i < categories.length; i++) {
              if (categories[i][CATEGORY_ID] == info[MENU_CATEGORY]) {
                category = listCategory[i + 1];
              }
            }
          }
          setState(() {});
        });
  }

  void _getFoodCategory() {
    AppModel().getFoodCategories(
      onSuccess: (List<Map<String, dynamic>> param) {
        categories = param;
        for (var element in categories) {
          listCategory.add(element[CATEGORY_NAME]);
        }
        setState(() {});
        _getFoodByID();
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    category = listCategory.first;
    _getFoodCategory();
  }

  @override
  void dispose() {
    listCategory = <String>['None'];
    categories.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter name.";
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
              child: TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.price_change),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter price.";
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
              child: TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter description.";
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
              child: DropdownButton<String>(
                underline: const SizedBox(
                  width: 1,
                ),
                value: category,
                borderRadius: BorderRadius.circular(10.0),
                icon: const Icon(Icons.keyboard_arrow_down),
                elevation: 16,
                onChanged: (String? value) {
                  debugPrint(value);
                  setState(() {
                    category = value!;
                  });
                },
                items:
                    listCategory.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ))),
    ));

    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child: const Text("Save", style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_nameController.text.trim() == '') return;
                if (_priceController.text.trim() == '') return;
                if (_descriptionController.text.trim() == '') return;

                String categoryID = '';
                for (var element in categories) {
                  if (element[CATEGORY_NAME] == category) {
                    categoryID = element[CATEGORY_ID];
                  }
                }

                AppModel().setFood(
                    id: widget.id,
                    name: _nameController.text.trim(),
                    price: _priceController.text.trim(),
                    desc: _descriptionController.text.trim(),
                    category: categoryID,
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getFoodByID();
                    });
              },
            ),
          )),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Edit"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: editView,
        ),
      ),
    );
  }
}
