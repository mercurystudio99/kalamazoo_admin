import 'package:kalamazoo_app_dashboard/constants/constants.dart';
import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:flutter/material.dart';

class DailySpecial extends StatefulWidget {
  const DailySpecial({Key? key}) : super(key: key);

  @override
  _DailySpecialState createState() => _DailySpecialState();
}

class _DailySpecialState extends State<DailySpecial> {
  static List<Map<String, dynamic>> dailyspecials = [];

  void _getDailySpecial() {
    AppModel().getDailySpecial(
      onSuccess: (List<Map<String, dynamic>> param) {
        dailyspecials = param;
        setState(() {});
      },
      onEmpty: () {},
    );
  }

  @override
  void initState() {
    super.initState();
    _getDailySpecial();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dailyspecialView = [];
    for (var i = 0; i < dailyspecials.length; i++) {
      dailyspecialView.add(Center(
        child: Container(
            width: double.maxFinite,
            height: 300,
            color: dailyspecials[i][DAILYSPECIAL_ACTIVE]
                ? Colors.grey[200]
                : Colors.grey[100],
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(dailyspecials[i][DAILYSPECIAL_IMAGE_LINK],
                        height: 250),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(dailyspecials[i][DAILYSPECIAL_DESC]),
                    ),
                    dailyspecials[i][DAILYSPECIAL_ACTIVE]
                        ? const Icon(Icons.circle, color: Colors.greenAccent)
                        : IconButton(
                            onPressed: () {
                              AppModel().publishDailySpecial(
                                id: dailyspecials[i][DAILYSPECIAL_ID],
                                onSuccess: () {
                                  _getDailySpecial();
                                },
                              );
                            },
                            icon: const Icon(Icons.circle,
                                color: Colors.redAccent)),
                  ],
                ))),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Specials"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dailyspecialView,
        ),
      ),
    );
  }
}
