import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class FoodCategoryEdit extends StatefulWidget {
  // Variables
  final String id;

  const FoodCategoryEdit({Key? key, required this.id}) : super(key: key);

  @override
  _FoodCategoryEditState createState() => _FoodCategoryEditState();
}

class _FoodCategoryEditState extends State<FoodCategoryEdit> {
  final _nameController = TextEditingController();

  late String name = '';

  void _getFoodCategory() {
    AppModel().getFoodCategory(
      id: widget.id,
      onSuccess: (param) {
        name = param![CATEGORY_NAME];
        _nameController.text = name;
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
                  const Text("Save a category", style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_nameController.text.trim() == '') return;
                AppModel().setFoodCategory(
                    id: widget.id,
                    name: _nameController.text.trim(),
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getFoodCategory();
                    });
              },
            ),
          )),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Category Edit"),
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
