import 'dart:math';

import 'package:elderly_app/models/appoinment.dart';
import 'package:elderly_app/others/database_helper.dart';
import 'package:elderly_app/screens/appoinment_reminder/appoinment_decision_screen.dart';
import 'package:elderly_app/screens/appoinment_reminder/appoinment_detail_screen.dart';
import 'package:elderly_app/screens/home/home_screen.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class AppoinmentReminder extends StatefulWidget {
  static const String id = 'Appoinment_Reminder_Screen';

  const AppoinmentReminder({Key? key}) : super(key: key);

  @override
  _AppoinmentReminderState createState() => _AppoinmentReminderState();
}

class _AppoinmentReminderState extends State<AppoinmentReminder> {
  final Random rng = Random();
  final TextStyle kTextStyle = const TextStyle(
      color: Colors.brown, fontSize: 15, fontWeight: FontWeight.w700);
  final DatabaseHelper databaseHelper = DatabaseHelper();

  // Initialize as empty lists.
  List<Appoinment> appoinmentList = [];
  late Appoinment appoinment;
  int count = 0;

  // Current date/time info.
  DateTime dateTime = DateTime.now();
  String year = DateTime.now().year.toString();
  String month = '';
  final Map<int, String> months = const {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  // A helper to set the current month string.
  void getMonth() {
    int monthDay = dateTime.month;
    month = months[monthDay] ?? '';
  }

  DateTime today = DateTime.now();
  final DateFormat f = DateFormat('yyyy-MM-dd hh:mm');

  // Lists for grouping appointments.
  List<Appoinment> todayAppoinment = [];
  List<Appoinment> upcomingAppoinment = [];
  List<Appoinment> pastAppoinment = [];

  // A list of widgets to display date numbers.
  List<Widget> textWidgets = [];

  @override
  void initState() {
    // Create empty lists for appointments.
    todayAppoinment = [];
    upcomingAppoinment = [];
    pastAppoinment = [];
    // Create a default appointment instance.
    appoinment = Appoinment(
      '',
      '',
      DateTime(1, 1, 1, 0, 0, 0).toString(),
      '',
      rng.nextInt(99999),
      false,
    );
    getMonth();
    getTextWidgets();
    super.initState();
  }

  // Build a row of text widgets representing consecutive dates.
  void getTextWidgets() {
    textWidgets = []; // clear any previous widgets
    int monthValue = dateTime.month;
    int yearValue = dateTime.year;
    int day = dateTime.day;
    int endDay;
    // Determine number of days in the month.
    if (monthValue == 1 ||
        monthValue == 3 ||
        monthValue == 5 ||
        monthValue == 7 ||
        monthValue == 8 ||
        monthValue == 10 ||
        monthValue == 12) {
      endDay = 31;
    } else if (monthValue == 2) {
      endDay = (yearValue % 4 == 0) ? 29 : 28;
    } else {
      endDay = 30;
    }
    // Today's date widget.
    Widget todayWidget = CircleAvatar(
      backgroundColor: Colors.blue,
      child: Text(
        day.toString(),
        style: const TextStyle(color: Colors.white),
      ),
    );
    int start = 1;
    for (var i = day; i <= day + 4; i++) {
      if (i > endDay) {
        textWidgets.add(Text(start.toString()));
        start++;
      } else {
        if (i == day) {
          textWidgets.add(todayWidget);
        } else {
          textWidgets.add(Text(i.toString()));
        }
      }
    }
  }

  // Retrieve today's appointments.
  Future<void> getTodayAppoinment() async {
    setState(() {
      todayAppoinment = [];
      for (Appoinment tempAppoinment in appoinmentList) {
        DateTime date = DateTime.parse(tempAppoinment.dateAndTime);
        if (today.day == date.day &&
            today.month == date.month &&
            today.year == date.year &&
            !tempAppoinment.done) {
          todayAppoinment.add(tempAppoinment);
        }
      }
    });
  }

  // Retrieve upcoming appointments.
  Future<void> getUpcomingAppoinment() async {
    setState(() {
      upcomingAppoinment = [];
      for (Appoinment tempAppoinment in appoinmentList) {
        DateTime date = DateTime.parse(tempAppoinment.dateAndTime);
        if (!todayAppoinment.contains(tempAppoinment) && today.isBefore(date)) {
          upcomingAppoinment.add(tempAppoinment);
        }
      }
    });
  }

  // Retrieve past appointments.
  Future<void> getPastAppoinment() async {
    setState(() {
      pastAppoinment = [];
      for (Appoinment tempAppoinment in appoinmentList) {
        DateTime date = DateTime.parse(tempAppoinment.dateAndTime);
        if (date.isBefore(today) && !todayAppoinment.contains(tempAppoinment)) {
          pastAppoinment.add(tempAppoinment);
        }
      }
    });
  }

  // Generate widget list for past appointments.
  List<Widget> getPastAppoinmentWidget(BuildContext context) {
    pastAppoinment.sort((a, b) => b.dateAndTime.compareTo(a.dateAndTime));
    List<Widget> pastAppoinmentWidgetList = [];
    for (Appoinment tempAppoinment in pastAppoinment) {
      DateTime dt = DateTime.parse(tempAppoinment.dateAndTime);
      String date =
          '${dt.day}/${dt.month}/${dt.year}';
      String time;
      if (dt.minute == 0) {
        time = '${dt.hour}:${dt.minute}0';
      } else if (dt.minute < 10) {
        time = '${dt.hour}:0${dt.minute}';
      } else {
        time = '${dt.hour}:${dt.minute}';
      }
      pastAppoinmentWidgetList.add(
        Builder(
          builder: (context) => InkWell(
            onLongPress: () async {
              _delete(context, tempAppoinment);
            },
            highlightColor: Colors.white70,
            child: OtherAppoinment(
              name: tempAppoinment.name,
              type: tempAppoinment.address,
              time: time,
              date: date,
            ),
          ),
        ),
      );
    }
    return pastAppoinmentWidgetList;
  }

  // Generate widget list for upcoming appointments.
  List<Widget> getUpcomingAppoinmentWidget(BuildContext context) {
    upcomingAppoinment.sort((a, b) => a.dateAndTime.compareTo(b.dateAndTime));
    List<Widget> upcomingAppoinmentWidgetList = [];
    for (Appoinment tempAppoinment in upcomingAppoinment) {
      DateTime dt = DateTime.parse(tempAppoinment.dateAndTime);
      String date =
          '${dt.day}/${dt.month}/${dt.year}';
      String time;
      if (dt.minute == 0) {
        time = '${dt.hour}:${dt.minute}0';
      } else if (dt.minute < 10) {
        time = '${dt.hour}:0${dt.minute}';
      } else {
        time = '${dt.hour}:${dt.minute}';
      }
      upcomingAppoinmentWidgetList.add(
        Builder(
          builder: (context) => InkWell(
            onTap: () {
              navigateToDetail(tempAppoinment, 'Edit');
            },
            onLongPress: () async {
              _showSnackBar(context, 'Appoinment Deleted');
              _delete(context, tempAppoinment);
            },
            child: OtherAppoinment(
              name: tempAppoinment.name,
              type: tempAppoinment.address,
              time: time,
              date: date,
            ),
          ),
        ),
      );
    }
    return upcomingAppoinmentWidgetList;
  }

  // Generate widget list for today's appointments.
  List<Widget> getTodayAppoinmentWidget(BuildContext context) {
    todayAppoinment.sort((a, b) => b.dateAndTime.compareTo(a.dateAndTime));
    List<Widget> todayAppoinmentWidgetList = [];
    for (Appoinment tempAppoinment in todayAppoinment) {
      DateTime dt = DateTime.parse(tempAppoinment.dateAndTime);
      String time;
      if (dt.minute == 0) {
        time = '${dt.hour}:${dt.minute}0';
      } else if (dt.minute < 10) {
        time = '${dt.hour}:0${dt.minute}';
      } else {
        time = '${dt.hour}:${dt.minute}';
      }
      // Determine the avatar color based on the appointment status.
      final Color avatarColor =
          tempAppoinment.done ? Colors.yellow : Colors.green;
      todayAppoinmentWidgetList.add(
        Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return AppoinmentDecision(tempAppoinment);
                }));
              },
              onLongPress: () async {
                _showSnackBar(context, 'Appoinment Done');
                setState(() {
                  tempAppoinment.done = true;
                });
                await databaseHelper.updateAppoinment(tempAppoinment);
              },
              leading: CircleAvatar(
                backgroundColor: avatarColor,
                radius: 38,
                child: const Icon(
                  FontAwesomeIcons.userMd,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              title: Text(
                tempAppoinment.name,
                style: kTextStyle.copyWith(
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              trailing: Text(time),
              subtitle:
                  Text('${tempAppoinment.address} at ${tempAppoinment.place}'),
            ),
          ),
        ),
      );
    }
    return todayAppoinmentWidgetList;
  }

  @override
  Widget build(BuildContext context) {
    // If the appointment list is empty, update it.
    if (appoinmentList.isEmpty) {
      updateListView();
    }
    // Refresh groupings.
    getTodayAppoinment();
    getUpcomingAppoinment();
    getPastAppoinment();

    return Scaffold(
      appBar: const ElderlyAppBar(),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          navigateToDetail(appoinment, 'Add');
        },
      ),
      body: WillPopScope(
        onWillPop: () {
          return Navigator.push(context,
              MaterialPageRoute(builder: (context) {
            return const HomeScreen();
          }));
        },
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 35),
            Text(
              '$month  $year',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 25, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: textWidgets,
            ),
            const SizedBox(height: 20),
            todayAppoinment.isEmpty
                ? const Center(child: Text('No Appointments today'))
                : Column(children: getTodayAppoinmentWidget(context)),
            const SizedBox(height: 17),
            const HeadingText(
              title: 'Upcoming',
              color: Colors.teal,
            ),
            const SizedBox(height: 8),
            upcomingAppoinment.isNotEmpty
                ? Column(children: getUpcomingAppoinmentWidget(context))
                : const Center(child: Text('No Upcoming Appointments')),
            const SizedBox(height: 15),
            const HeadingText(
              title: 'Past Appointments',
              color: Colors.deepOrangeAccent,
            ),
            const SizedBox(height: 10),
            pastAppoinment.isNotEmpty
                ? Column(children: getPastAppoinmentWidget(context))
                : Container(
                    margin: const EdgeInsets.only(bottom: 35),
                    child: const Center(child: Text('No past Appointments')),
                  ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Delete an appointment.
  void _delete(BuildContext context, Appoinment appoinment) async {
    int result = await databaseHelper.deleteAppoinment(appoinment.id);
    if (result != 0) {
      updateListView();
    }
  }

  // Navigate to the appointment detail screen.
  void navigateToDetail(Appoinment appoinment, String action) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return AppoinmentDetail(appoinment, action);
      }),
    );
    if (result == true) {
      updateListView();
    }
  }

  // Update the appointment list from the database.
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Appoinment>> appoinmentListFuture =
          databaseHelper.getAppoinmentList();
      appoinmentListFuture.then((list) {
        setState(() {
          appoinmentList = list;
          count = list.length;
        });
      });
    });
  }

  // Display a snack bar message.
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class HeadingText extends StatelessWidget {
  final String title;
  final Color color;
  const HeadingText({Key? key, required this.title, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 20),
      child: Text(
        '$title :',
        style: TextStyle(
            color: color, fontSize: 23, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class OtherAppoinment extends StatelessWidget {
  final String time;
  final String date;
  final String type;
  final String name;
  const OtherAppoinment(
      {Key? key,
      required this.name,
      required this.date,
      required this.type,
      required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(25),
          right: Radius.circular(25),
        ),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 25),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 5),
                Text(
                  'Dr. $name',
                  style: const TextStyle(
                      fontSize: 19,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  type,
                  style:
                      const TextStyle(color: Colors.brown, fontSize: 16),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  date,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  time,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TodayAppoinment extends StatelessWidget {
  final String time;
  final String place;
  final String name;
  final String type;
  final TextStyle kTextStyle;
  const TodayAppoinment(
      {Key? key,
      required this.type,
      required this.name,
      required this.place,
      required this.time,
      required this.kTextStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      decoration: BoxDecoration(
        color: const Color(0xfff5f5f5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 38,
                  child: Icon(
                    FontAwesomeIcons.userMd,
                    size: 43,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                  child: Text(
                    time,
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Text(
              'Dr. $name',
              style: kTextStyle.copyWith(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  fontSize: 19),
            ),
          )
        ],
      ),
    );
  }
}
