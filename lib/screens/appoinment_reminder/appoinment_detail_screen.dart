import 'dart:math';
import 'package:elderly_app/models/appoinment.dart';
import 'package:elderly_app/others/database_helper.dart';
import 'package:elderly_app/others/notification_service.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';

class AppoinmentDetail extends StatefulWidget {
  static const String id = 'Appoinment_Detail_Screen';
  final String pageTitle;
  final Appoinment appoinment;

  const AppoinmentDetail({
    Key? key,
    required this.appoinment,
    required this.pageTitle,
  }) : super(key: key);

  @override
  State<AppoinmentDetail> createState() => _AppoinmentDetailState();
}

class _AppoinmentDetailState extends State<AppoinmentDetail> {
  final DatabaseHelper helper = DatabaseHelper();
  late Appoinment appoinment;
  final Random rng = Random();
  late int notificationID;
  String doctorName = '';
  String place = '';
  String address = '';
  late DateTime date;
  late DateTime dateCheck;
  late DateTime tempDate;
  TimeOfDay timeSelected = const TimeOfDay(hour: 0, minute: 0);
  late NotificationService notificationService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController addressController = TextEditingController(text: '');
  final DateFormat dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  final DateFormat f = DateFormat('yyyy-MM-dd hh:mm');

  @override
  void initState() {
    super.initState();
    appoinment = widget.appoinment;
    doctorName = nameController.text = appoinment.name;
    place = placeController.text = appoinment.place;
    address = addressController.text = appoinment.address;
    date = dateCheck = DateTime.parse(appoinment.dateAndTime);
    tempDate = DateTime(date.year, date.month, date.day);
    timeSelected = TimeOfDay(hour: date.hour, minute: date.minute);
    notificationID = appoinment.notificationId;
    notificationService = NotificationService();
    notificationService.initialize();
  }

  @override
  void dispose() {
    nameController.dispose();
    placeController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        tempDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const ElderlyAppBar(),
      body: WillPopScope(
        onWillPop: () async {
          // Create a temporary appointment instance for comparison.
          final Appoinment tempAppoinment = Appoinment(
            doctorName,
            place,
            date.toString(),
            address,
            notificationID,
            false,
          );
          if (appoinment != tempAppoinment) {
            return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return RichAlertDialog(
                      alertTitle: richTitle("Reminder Not Saved"),
                      alertSubtitle: richSubtitle('Changes will be discarded'),
                      alertType: RichAlertType.WARNING,
                      actions: <Widget>[
                        TextButton(
                          child: const Text("OK"),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                        ),
                        TextButton(
                          child: const Text("No"),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                    );
                  },
                ) ??
                false;
          } else {
            return true;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${widget.pageTitle} Appoinment',
                    style: const TextStyle(color: Colors.green, fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              AppoinmentFormItem(
                helperText: 'Full name',
                hintText: 'Enter name of the Doctor',
                controller: nameController,
                onChanged: (value) {
                  setState(() {
                    doctorName = value;
                  });
                },
                isNumber: false,
                icon: FontAwesomeIcons.userMd,
              ),
              const SizedBox(height: 8),
              AppoinmentFormItem(
                helperText: 'Hospital , Home',
                hintText: 'Enter place of Visit',
                controller: placeController,
                onChanged: (value) {
                  setState(() {
                    place = value;
                  });
                },
                isNumber: false,
                icon: FontAwesomeIcons.clinicMedical,
              ),
              const SizedBox(height: 8),
              AppoinmentFormItem(
                helperText: 'Any Specialization',
                hintText: 'Enter type',
                controller: addressController,
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
                isNumber: false,
                icon: FontAwesomeIcons.briefcaseMedical,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Date',
                          style: TextStyle(color: Colors.teal),
                        ),
                        InkWell(
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.event_note,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () async {
                            await _selectDate();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Time',
                          style: TextStyle(color: Colors.teal),
                        ),
                        InkWell(
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.alarm_add,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () async {
                            showMaterialTimePicker(
                              context: context,
                              selectedTime: timeSelected,
                              onChanged: (TimeOfDay value) {
                                setState(() {
                                  timeSelected = value;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 16, 18, 1),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    primary: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                  ),
                  onPressed: () async {
                    if (!(timeSelected.minute == 0 && timeSelected.hour == 0)) {
                      if (!(tempDate.year == 0 &&
                          tempDate.month == 0 &&
                          tempDate.day == 0)) {
                        setState(() {
                          date = DateTime(
                            tempDate.year,
                            tempDate.month,
                            tempDate.day,
                            timeSelected.hour,
                            timeSelected.minute,
                          );
                        });
                        await _save();
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    '${widget.pageTitle} Appoinment',
                    style: const TextStyle(color: Colors.white, fontSize: 23),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Save data to database.
  Future<void> _save() async {
    appoinment.dateAndTime = f.format(date);
    appoinment.name = doctorName;
    appoinment.address = address;
    appoinment.place = place;

    int result;
    if (appoinment.id != null) {
      // Update operation.
      result = await helper.updateAppoinment(appoinment);
    } else {
      // Insert operation.
      appoinment.notificationId = rng.nextInt(9999);
      result = await helper.insertAppoinment(appoinment);
      if (date.isAfter(DateTime.now())) {
        notificationService.scheduleAppoinmentNotification(
          id: appoinment.notificationId,
          title: appoinment.name,
          body: '${appoinment.place} ${appoinment.address}',
          dateTime: date,
        );
      }
    }
    if (date != dateCheck) {
      notificationService.deleteNotification(appoinment.notificationId);
      if (date.isAfter(DateTime.now())) {
        notificationService.scheduleAppoinmentNotification(
          id: appoinment.notificationId,
          title: appoinment.name,
          body: '${appoinment.place} ${appoinment.address}',
          dateTime: date,
        );
      }
    }
    if (result != 0) {
      Navigator.pop(context);
    } else {
      _showAlertDialog('Status', 'Problem Saving Appoinment');
    }
  }

  void _showAlertDialog(String title, String message) {
    final AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

class AppoinmentFormItem extends StatelessWidget {
  final String hintText;
  final String helperText;
  final ValueChanged<String> onChanged;
  final bool isNumber;
  final IconData icon;
  final TextEditingController controller;

  const AppoinmentFormItem({
    Key? key,
    required this.hintText,
    required this.helperText,
    required this.onChanged,
    required this.icon,
    this.isNumber = false,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xffaf5676),
              style: BorderStyle.solid,
            ),
          ),
          prefixIcon: Icon(icon, color: Colors.green),
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.indigo,
              style: BorderStyle.solid,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color(0xffaf5676),
              style: BorderStyle.solid,
            ),
          ),
        ),
        onChanged: onChanged,
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
