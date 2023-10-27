import 'package:kalamazoo_app_dashboard/models/app_model.dart';
import 'package:kalamazoo_app_dashboard/widgets/default_button.dart';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year);
final kLastDay = DateTime(2050);

final kEvents = LinkedHashMap<DateTime, List<EventItem>>(
    equals: isSameDay, hashCode: getHashCode);

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

class Event extends StatefulWidget {
  const Event({Key? key}) : super(key: key);

  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> {
  final _storage = FirebaseStorage.instance;
  PlatformFile? _imageFile;
  String _imageLink = '';
  List<String> banners = [];

  late final ValueNotifier<List<EventItem>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final Map<DateTime, List<EventItem>> _kEventSource = {};

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  void _getBanners() {
    AppModel().getEventBanners(
      onSuccess: (List<String> param) {
        banners = param;
        setState(() {});
      },
    );
  }

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
          await _storage.ref().child('event/$filename').putData(fileBytes!);

      var url = await snapshot.ref.getDownloadURL();

      AppModel().setEventBanners(
          imageUrl: url.toString(),
          onSuccess: () {
            onCallback();
          },
          onError: () {});
    }
  }

  List<EventItem> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _showAddEventDialog() async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('New Event'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTextField(
                      controller: _titleController, hint: 'Enter Title'),
                  const SizedBox(
                    height: 20.0,
                  ),
                  buildTextField(
                      controller: _descController, hint: 'Enter Description'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty &&
                        _descController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter title & description'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    } else {
                      setState(() {
                        if (_kEventSource[_selectedDay] != null) {
                          _kEventSource[_selectedDay]?.add(EventItem(
                              eventTitle: _titleController.text,
                              eventDesc: _descController.text,
                              eventColor: Colors.primaries[
                                  Random().nextInt(Colors.primaries.length)]));
                        } else {
                          _kEventSource[_selectedDay!] = [
                            EventItem(
                                eventTitle: _titleController.text,
                                eventDesc: _descController.text,
                                eventColor: Colors.primaries[
                                    Random().nextInt(Colors.primaries.length)])
                          ];
                        }
                        kEvents.addAll(_kEventSource);
                      });

                      _titleController.clear();
                      _descController.clear();

                      Navigator.pop(context);
                      return;
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    _getBanners();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bannerList = banners
        .map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Center(
                      child: CachedNetworkImage(
                    imageUrl: item,
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
            ))
        .toList();

    return Scaffold(
        appBar: AppBar(
          title: const Text("Event"),
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () => _showAddEventDialog(),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: ListView(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15),
                  children: bannerList),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(children: [
                      _imageFile != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: Center(
                                          child: CachedNetworkImage(
                                        imageUrl: _imageLink,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ))),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: Center(
                                          child: Container(
                                        width: 200,
                                        height: 200,
                                        color: Colors.grey,
                                      )))),
                    ]))),
            SizedBox(
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
                            child: const Text("Delete",
                                style: TextStyle(fontSize: 18)),
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                                _imageLink = '';
                              });
                            },
                          ),
                        ]))),
            SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: DefaultButton(
                    child: const Text("Save Event",
                        style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      _saveImage(onCallback: () {
                        _getBanners();
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
            TableCalendar<EventItem>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                headerMargin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                titleCentered: true,
                titleTextStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                leftChevronIcon:
                    const Icon(Icons.chevron_left, color: Colors.black45),
                rightChevronIcon:
                    const Icon(Icons.chevron_right, color: Colors.black45),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      blurRadius: 30.0,
                    ),
                  ],
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                tablePadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                todayDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                singleMarkerBuilder: (context, date, event) {
                  Color color = event.eventColor;
                  return Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: color),
                    width: 7.0,
                    height: 7.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  );
                },
              ),
            ),
          ],
        ));
  }

  Widget buildTextField(
      {String? hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: hint ?? '',
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }
}

class EventItem {
  final String eventTitle;
  final String eventDesc;
  final Color eventColor;

  EventItem(
      {required this.eventTitle,
      required this.eventDesc,
      required this.eventColor});

  @override
  String toString() => eventTitle;
}
