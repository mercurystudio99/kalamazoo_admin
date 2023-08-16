import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_card_border.dart';
import 'package:kalamazoo_app_dashboard/widgets/show_scaffold_msg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Restaurant extends StatefulWidget {
  const Restaurant({Key? key}) : super(key: key);

  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<Restaurant> {
  late bool _restaurantImageExist = false;
  late int _menuCount = 0;
  late Map<String, dynamic> _restaurant = {};
  PlatformFile? _imageFile;
  PlatformFile? _restaurantImage;
  // Variables
  final _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  static List<Map<String, dynamic>> categories = [];

  static List<String> listCategory = <String>['None'];
  String category = '';

  Future getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null) return;
    setState(() {
      _imageFile = result.files.first;
    });
  }

  Future getRestaurantImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null) return;
    setState(() {
      _restaurantImage = result.files.first;
    });
  }

  void _save(
      {required VoidCallback onCallback,
      required Function(String) onError}) async {
    if (_imageFile != null) {
      Uint8List? fileBytes = _imageFile!.bytes;
      String filename =
          DateTime.now().millisecondsSinceEpoch.toString() + _imageFile!.name;
      var snapshot =
          await _storage.ref().child('menu/$filename').putData(fileBytes!);

      var url = await snapshot.ref.getDownloadURL();

      String categoryID = '';
      for (var element in categories) {
        if (element[CATEGORY_NAME] == category) {
          categoryID = element[CATEGORY_ID];
        }
      }

      AppModel().saveMenu(
          imageUrl: url.toString(),
          name: _nameController.text.trim(),
          price: _priceController.text.trim(),
          desc: _descriptionController.text.trim(),
          category: categoryID,
          onSuccess: () {
            onCallback();
          },
          onError: () {});
    } else {
      // String categoryID = '';
      // for (var element in categories) {
      //   if (element[CATEGORY_NAME] == category) {
      //     categoryID = element[CATEGORY_ID];
      //   }
      // }
      // AppModel().saveMenu(
      //     imageUrl: '',
      //     name: _nameController.text.trim(),
      //     price: _priceController.text.trim(),
      //     desc: _descriptionController.text.trim(),
      //     category: categoryID,
      //     onSuccess: () {
      //       onCallback();
      //     },
      //     onError: () {});
      onError("Please upload an menu image.");
    }
  }

  void _saveRestaurantImage(
      {required VoidCallback onCallback,
      required Function(String) onError}) async {
    if (_restaurantImage != null) {
      Uint8List? fileBytes = _restaurantImage!.bytes;
      String filename = DateTime.now().millisecondsSinceEpoch.toString() +
          _restaurantImage!.name;
      var snapshot = await _storage
          .ref()
          .child('restaurant/$filename')
          .putData(fileBytes!);

      var url = await snapshot.ref.getDownloadURL();

      AppModel().updateRestaurantImage(
          imageUrl: url.toString(),
          onSuccess: () {
            onCallback();
          },
          onError: () {});
    } else {
      onError("Please upload an restaurant image.");
    }
  }

  void _getRestaurant() {
    AppModel().getRestaurantByID(onSuccess: (Map<String, dynamic>? data) {
      _restaurant = data!;
      if (data[RESTAURANT_IMAGE] != null) {
        _restaurantImageExist = true;
      }
      setState(() {});
    });
  }

  void _getMenu() {
    AppModel().getMenu(
      onSuccess: (list) {
        _menuCount = list.length;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  void _getFoodCategory() {
    AppModel().getFoodCategories(
      onSuccess: (List<Map<String, dynamic>> param) {
        categories = param;
        for (var element in categories) {
          listCategory.add(element[CATEGORY_NAME]);
        }
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    category = listCategory.first;
    _getRestaurant();
    _getMenu();
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(_restaurant[RESTAURANT_BUSINESSNAME] ?? "Restaurant"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30.0),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              shape: defaultCardBorder(),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Text(
                          "Menu Count: $_menuCount",
                          style: const TextStyle(fontSize: 20),
                        )),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30.0,
                          ),
                        ],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _imageFile != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      Uint8List.fromList(_imageFile!.bytes!),
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: const Icon(
                                    Icons.camera,
                                    size: 30,
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'Click here to upload an image!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                hintText: "Enter menu title.",
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                prefixIcon: const Icon(Icons.title)),
                            validator: (name) {
                              // Basic validation
                              if (name?.isEmpty ?? true) {
                                return "Please enter a menu title.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              hintText: "Enter menu price.",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.money),
                            ),
                            validator: (price) {
                              if (price?.isEmpty ?? true) {
                                return "Please enter a menu price.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              hintText: "Enter menu description.",
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              prefixIcon: const Icon(Icons.description),
                            ),
                            validator: (desc) {
                              if (desc?.isEmpty ?? true) {
                                return "Please enter a menu description.";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButton<String>(
                            underline: const SizedBox(
                              width: 1,
                            ),
                            value: category,
                            borderRadius: BorderRadius.circular(10.0),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            elevation: 16,
                            onChanged: (String? value) {
                              setState(() {
                                category = value!;
                              });
                            },
                            items: listCategory
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.maxFinite,
                            child: DefaultButton(
                              child: const Text("Add a Menu",
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                /// Validate form
                                if (_formKey.currentState!.validate()) {
                                  _save(onCallback: () {
                                    _nameController.text = '';
                                    _priceController.text = '';
                                    setState(() {
                                      _menuCount = _menuCount + 1;
                                    });
                                    showScaffoldMessage(
                                        context: context,
                                        scaffoldkey: _scaffoldKey,
                                        bgcolor: Colors.black,
                                        message: "Success!");
                                  }, onError: (String text) {
                                    showScaffoldMessage(
                                        context: context,
                                        scaffoldkey: _scaffoldKey,
                                        bgcolor: Theme.of(context).splashColor,
                                        message: text);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(children: [
                          _restaurantImage != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      Uint8List.fromList(
                                          _restaurantImage!.bytes!),
                                      width: 300,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    getRestaurantImage();
                                  },
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                  ),
                                ),
                          GestureDetector(
                            onTap: () {
                              getRestaurantImage();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'Click here to upload an restaurant image!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (!_restaurantImageExist)
                            SizedBox(
                              width: double.maxFinite,
                              child: DefaultButton(
                                child: const Text("Save a Restaurant Image",
                                    style: TextStyle(fontSize: 16)),
                                onPressed: () {
                                  _saveRestaurantImage(onCallback: () {
                                    setState(() {
                                      _restaurantImageExist = true;
                                    });
                                    showScaffoldMessage(
                                        context: context,
                                        scaffoldkey: _scaffoldKey,
                                        bgcolor: Colors.black,
                                        message: "Success!");
                                  }, onError: (String text) {
                                    showScaffoldMessage(
                                        context: context,
                                        scaffoldkey: _scaffoldKey,
                                        bgcolor: Theme.of(context).splashColor,
                                        message: text);
                                  });
                                },
                              ),
                            )
                        ]))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
