import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';

class AmenityEdit extends StatefulWidget {
  // Variables
  final String id;

  const AmenityEdit({Key? key, required this.id}) : super(key: key);

  @override
  _AmenityEditState createState() => _AmenityEditState();
}

class _AmenityEditState extends State<AmenityEdit> {
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();

  late String name = '';
  late String logo = '';

  void _getAmenity() {
    AppModel().getAmenity(
      id: widget.id,
      onSuccess: (param) {
        name = param![AMENITY_NAME];
        logo = param[AMENITY_LOGO] ?? '';
        _nameController.text = name;
        _logoController.text = logo;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    _getAmenity();
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
                  hintText: "Enter amenity name.",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (name) {
                  if (name?.isEmpty ?? true) {
                    return "Please enter an amenity name.";
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
                controller: _logoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  hintText: "Enter amenity logo id.",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.image_search),
                ),
                validator: (logo) {
                  if (logo?.isEmpty ?? true) {
                    return "Please enter an amenity logo id.";
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
              child: const Text("Save", style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_nameController.text.trim() == '') return;
                if (_logoController.text.trim() == '') return;
                AppModel().setAmenity(
                    id: widget.id,
                    name: _nameController.text.trim(),
                    logo: _logoController.text.trim(),
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getAmenity();
                    });
              },
            ),
          )),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Amenity Edit"),
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
