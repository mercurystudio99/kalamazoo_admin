import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'package:kalamazoo_app_dashboard/screens/food_edit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantEdit extends StatefulWidget {
  // Variables
  final String id;

  const RestaurantEdit({Key? key, required this.id}) : super(key: key);

  @override
  _RestaurantEditState createState() => _RestaurantEditState();
}

class _RestaurantEditState extends State<RestaurantEdit> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _stateController = TextEditingController();
  final _urlController = TextEditingController();
  final _zipController = TextEditingController();

  Map<String, dynamic> info = {};
  late List<Map<String, dynamic>> amenities = [];
  late List<Map<String, dynamic>> topMenuList = [];
  late final Map<String, dynamic> _isCheckedAmenities = {};
  List<QueryDocumentSnapshot<Map<String, dynamic>>> foodInfo = [];

  final _storage = FirebaseStorage.instance;
  PlatformFile? _imageFile;
  String _imageLink = '';
  String _selectedTopMenu = '';

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
    }
  }

  void _saveAmenities(
      {required VoidCallback onCallback, required Function(String) onError}) {
    List<dynamic> checkedAmenities = [];
    for (var element in amenities) {
      if (_isCheckedAmenities[element[AMENITY_ID]] == true) {
        checkedAmenities.add(element[AMENITY_ID]);
      }
    }

    AppModel().updateRestaurantAmenities(
        list: checkedAmenities,
        onSuccess: () {
          onCallback();
        });
  }

  void _getRestaurantByID() {
    AppModel().getRestaurantByID(onSuccess: (param) {
      info = param!;
      if (info[RESTAURANT_IMAGE] != null) {
        _imageLink = info[RESTAURANT_IMAGE];
      }
      _nameController.text = info[RESTAURANT_BUSINESSNAME];
      _addressController.text = info[RESTAURANT_ADDRESS];
      _cityController.text = info[RESTAURANT_CITY];
      _emailController.text = info[RESTAURANT_EMAIL];
      _phoneController.text = info[RESTAURANT_PHONE];
      _stateController.text = info[RESTAURANT_STATE];
      _urlController.text = info[RESTAURANT_URL];
      _zipController.text = info[RESTAURANT_ZIP];
      if (info[RESTAURANT_CATEGORY] != null) {
        _selectedTopMenu = info[RESTAURANT_CATEGORY];
      }
      setState(() {});
    });
  }

  void _getFoods() {
    AppModel().getMenu(
        onSuccess: (param) {
          foodInfo = param;
          setState(() {});
        },
        onEmpty: () {});
  }

  void _getAmenities() {
    AppModel().getAmenities(
      onSuccess: (List<Map<String, dynamic>> param) {
        amenities = param;
        for (var element in amenities) {
          _isCheckedAmenities[element[AMENITY_ID]] = false;
        }
        if (info[RESTAURANT_AMENITIES] != null) {
          for (var id in info[RESTAURANT_AMENITIES]) {
            _isCheckedAmenities[id] = true;
          }
        }
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  void _getTopMenu() {
    AppModel().getTopMenu(
      onSuccess: (List<Map<String, dynamic>> param) {
        topMenuList = param;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  // void _getTemp() {
  //   AppModel().getTemp(
  //     onSuccess: () {},
  //     onEmpty: () {},
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _getRestaurantByID();
    _getFoods();
    _getAmenities();
    _getTopMenu();
    // _getTemp();
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
              child: Text('Restaurant Information',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 22)))),
    ));

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
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter address.";
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
                controller: _cityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter city.";
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
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter email.";
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
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter phone.";
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
                controller: _stateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.circle),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter state.";
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
                controller: _urlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.web),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter url.";
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
                controller: _zipController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const Icon(Icons.location_searching),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return "Please enter zip.";
                  }
                  return null;
                },
              ))),
    ));
    editView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          height: 70,
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: topMenuList.map((topmenu) {
                  return categoryBox(topmenu, Theme.of(context).primaryColor);
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
                if (_addressController.text.trim() == '') return;
                if (_cityController.text.trim() == '') return;
                if (_emailController.text.trim() == '') return;
                if (_phoneController.text.trim() == '') return;
                if (_stateController.text.trim() == '') return;
                if (_urlController.text.trim() == '') return;
                if (_zipController.text.trim() == '') return;
                if (_selectedTopMenu.isEmpty) return;
                AppModel().setRestaurantByID(
                    id: widget.id,
                    name: _nameController.text.trim(),
                    address: _addressController.text.trim(),
                    city: _cityController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    state: _stateController.text.trim(),
                    url: _urlController.text.trim(),
                    zip: _zipController.text.trim(),
                    topmenu: _selectedTopMenu,
                    onSuccess: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Success!')),
                      );
                      _getRestaurantByID();
                    });
              },
            ),
          )),
    ));

    List<Widget> menuView = [];
    menuView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Food Information',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 22)))),
    ));
    if (foodInfo.isNotEmpty) {
      for (var element in foodInfo) {
        var info = element.data();
        menuView.add(Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: Text(info[MENU_NAME]),
                    subtitle: Text("\$${info[MENU_PRICE]}"),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  FoodEdit(id: info[MENU_ID])));
                        },
                        icon: const Icon(Icons.edit)),
                  ))),
        ));
      }
    } else {
      menuView.add(Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: const Padding(
                padding: EdgeInsets.all(10),
                child: Text('No menu', style: TextStyle(fontSize: 15)))),
      ));
    }
    menuView.add(Center(
      child:
          SizedBox(width: MediaQuery.of(context).size.width / 2, height: 100),
    ));

    List<Widget> amenitiesView = [];
    amenitiesView.add(_listing());
    amenitiesView.add(Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DefaultButton(
              child:
                  const Text("Save Amenities", style: TextStyle(fontSize: 18)),
              onPressed: () {
                _saveAmenities(onCallback: () {
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
    amenitiesView.add(Center(
      child:
          SizedBox(width: MediaQuery.of(context).size.width / 2, height: 100),
    ));

    List<Widget> listView = [...editView, ...menuView, ...amenitiesView];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Edit"),
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

  Widget _listing() {
    Size size = MediaQuery.of(context).size;
    int length = 30;
    double itemWidth = 300;
    if (size.width < 1400) {
      length = 30;
    }
    if (size.width < 1200) {
      length = 20;
    }
    if (size.width < 600) {
      length = 12;
    }

    List<Widget> lists = amenities.map((item) {
      return SizedBox(
          width: itemWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 5,
                        spreadRadius: 1),
                  ],
                ),
                child: ColoredBox(
                    color: Colors.white,
                    child: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        side: const BorderSide(color: Colors.white),
                        checkColor: Colors.white,
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.blueAccent;
                          }
                          return Colors.blueAccent;
                        }),
                        value: _isCheckedAmenities[item[AMENITY_ID]],
                        onChanged: (bool? value) {
                          setState(() {
                            _isCheckedAmenities[item[AMENITY_ID]] = value!;
                          });
                        },
                      ),
                    )),
              ),
              const SizedBox(width: 5),
              Image.asset(
                'assets/images/amenities/icon (${item[AMENITY_LOGO]}).png',
              ),
              const SizedBox(width: 5),
              Text(item[AMENITY_NAME].toString().length < length
                  ? item[AMENITY_NAME]
                  : '${item[AMENITY_NAME].toString().substring(0, length - 2)}..')
            ]),
          ));
    }).toList();
    int rowCount = lists.length ~/ 2;
    List<Widget> rowList = [];
    for (int i = 0; i < rowCount + 1; i++) {
      if (lists.length > 2 * (i + 1)) {
        rowList.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: lists.sublist(2 * i, 2 * (i + 1))));
      } else {
        rowList.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: lists.sublist(2 * i, lists.length)));
      }
    }

    return Center(
        child: SizedBox(
      width: itemWidth * 2 + 10,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: rowList),
    ));
  }

  Widget categoryBox(Map<String, dynamic> item, Color backgroundcolor) {
    return InkWell(
        onTap: () {
          setState(() {
            _selectedTopMenu = item[TOPMENU_ID];
          });
        },
        child: Container(
            margin:
                const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 12),
            width: 65,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: _selectedTopMenu == item[TOPMENU_ID]
                  ? Colors.redAccent
                  : backgroundcolor,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/topmenu/${item[TOPMENU_IMAGE]}.png",
                    width: 25, height: 25),
                Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        item[TOPMENU_NAME].toString().length <= 10
                            ? item[TOPMENU_NAME].toString()
                            : '${item[TOPMENU_NAME].toString().substring(0, 8)}..',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10))),
              ],
            )));
  }
}
