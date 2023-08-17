import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  final _storage = FirebaseStorage.instance;
  PlatformFile? _imageFile;
  String _imageLink = '';

  Future getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null) return;
    setState(() {
      _imageFile = result.files.first;
      _imageLink = '';
    });
  }

  void _saveImage(
      {required VoidCallback onCallback,
      required Function(String) onError}) async {
    if (_imageFile != null) {
      Uint8List? fileBytes = _imageFile!.bytes;
      String filename =
          DateTime.now().millisecondsSinceEpoch.toString() + _imageFile!.name;
      var snapshot =
          await _storage.ref().child('menu/$filename').putData(fileBytes!);

      var url = await snapshot.ref.getDownloadURL();

      AppModel().updateFoodImage(
          id: widget.id,
          imageUrl: url.toString(),
          onSuccess: () {
            onCallback();
          },
          onError: () {});
    }
  }

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
          if (info[MENU_PHOTO_LINK] != null) {
            _imageLink = info[MENU_PHOTO_LINK];
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
              child: Stack(children: [
                _imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: Center(
                                child: Image.memory(
                              Uint8List.fromList(_imageFile!.bytes!),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ))),
                      )
                    : _imageLink.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Center(
                                    child: CachedNetworkImage(
                                  imageUrl: _imageLink,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ))),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Center(
                                    child: Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey,
                                )))),
              ]))),
    ));
    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultButton(
                      child: const Text("Upload New",
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        getImage();
                      },
                    ),
                    DefaultButton(
                      child: const Text("Delete photo",
                          style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                          _imageLink = '';
                        });
                      },
                    ),
                  ]))),
    ));
    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child: const Text("Save Image", style: TextStyle(fontSize: 18)),
              onPressed: () {
                _saveImage(onCallback: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Success.')),
                  );
                }, onError: (String text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(text)),
                  );
                });
              },
            ),
          )),
    ));

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
                    child: Text(value.length < 30
                        ? value
                        : value.substring(0, 28) + '..'),
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
