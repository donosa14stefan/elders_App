import 'package:elderly_app/models/appoinment.dart';
import 'package:elderly_app/others/database_helper.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:flutter/material.dart';

class AppoinmentDecision extends StatefulWidget {
  static const String id = 'Appoinment_decision_screen';
  final Appoinment appoinment;
  
  const AppoinmentDecision({Key? key, required this.appoinment}) : super(key: key);
  
  @override
  _AppoinmentDecisionState createState() => _AppoinmentDecisionState();
}

class _AppoinmentDecisionState extends State<AppoinmentDecision> {
  final DatabaseHelper helper = DatabaseHelper();
  late Appoinment appoinment;
  
  @override
  void initState() {
    super.initState();
    appoinment = widget.appoinment;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ElderlyAppBar(),
      drawer: const AppDrawer(),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Did you visit ${appoinment.name}',
                style: const TextStyle(fontSize: 30, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.check,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        appoinment.done = true;
                      });
                      await helper.updateAppoinment(appoinment);
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.red,
                      child: const Icon(
                        Icons.close,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                    onTap: () async {
                      setState(() {
                        appoinment.done = false;
                      });
                      await helper.updateAppoinment(appoinment);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
