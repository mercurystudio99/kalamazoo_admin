import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:kalamazoo_app_dashboard/screens/amenities_edit.dart';
import 'package:flutter/material.dart';

class Amenities extends StatefulWidget {
  const Amenities({Key? key}) : super(key: key);

  @override
  _AmenitiesState createState() => _AmenitiesState();
}

class _AmenitiesState extends State<Amenities> {
  static List<Map<String, dynamic>> amenities = [];

  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _typeController = TextEditingController();

  void _reloadData() {
    _getAmenities();
  }

  void _getAmenities() {
    AppModel().getAmenities(
      onSuccess: (List<Map<String, dynamic>> param) {
        amenities = param;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    _getAmenities();
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
              child: TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  hintText: "Enter amenity type.",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (type) {
                  if (type?.isEmpty ?? true) {
                    return "Please enter an amenity type.";
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
                  const Text("Add an Amenity", style: TextStyle(fontSize: 18)),
              onPressed: () {
                if (_nameController.text.trim() == '') return;
                if (_logoController.text.trim() == '') return;
                if (_typeController.text.trim() == '') return;
                AppModel().setAmenities(
                    name: _nameController.text.trim(),
                    logo: _logoController.text.trim(),
                    type: _typeController.text.trim(),
                    onSuccess: () {
                      _nameController.text = '';
                      _logoController.text = '';
                      _typeController.text = '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getAmenities();
                    });
              },
            ),
          )),
    ));

    List<Widget> amenitiesView = [];
    for (var i = 0; i < amenities.length; i++) {
      amenitiesView.add(Center(
        child: SizedBox(
            width: 350,
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(amenities[i][AMENITY_NAME]),
              ),
              subtitle: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(amenities[i][AMENITY_TYPE] ?? '')),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AmenityEdit(
                            id: amenities[i][AMENITY_ID],
                            reloadData: _reloadData)));
                    _reloadData();
                  },
                  icon: const Icon(Icons.edit)),
            )),
      ));
    }

    listView = [...editView, ...amenitiesView];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amenities"),
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
