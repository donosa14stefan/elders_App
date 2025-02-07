import 'package:elderly_app/models/appoinment.dart';
import 'package:elderly_app/models/reminder.dart';
import 'package:elderly_app/others/auth.dart';
import 'package:elderly_app/resources/service_locator.dart';
import 'package:elderly_app/screens/appoinment_reminder/appoinment_decision_screen.dart';
import 'package:elderly_app/screens/appoinment_reminder/appoinment_detail_screen.dart';
import 'package:elderly_app/screens/appoinment_reminder/appoinment_reminder_screen.dart';
import 'package:elderly_app/screens/document/add_documents_screen.dart';
import 'package:elderly_app/screens/document/view_documents_screen.dart';
import 'package:elderly_app/screens/home/home_screen.dart';
import 'package:elderly_app/screens/hospital/nearby_hospital_screen.dart';
import 'package:elderly_app/screens/loading/loading_screen.dart';
import 'package:elderly_app/screens/loading/onBoarding_screen.dart';
import 'package:elderly_app/screens/login/initial_setup_screen.dart';
import 'package:elderly_app/screens/login/login_screen.dart';
import 'package:elderly_app/screens/medicine_reminder/medicine_reminder.dart';
import 'package:elderly_app/screens/medicine_reminder/reminder_detail.dart';
import 'package:elderly_app/screens/notes/note_home_screen.dart';
import 'package:elderly_app/screens/pages/heart_rate_screen.dart';
import 'package:elderly_app/screens/pages/image_label.dart';
import 'package:elderly_app/screens/profile/profile_edit_screen.dart';
import 'package:elderly_app/screens/profile/profile_screen.dart';
import 'package:elderly_app/screens/relatives/contact_relatives_screen.dart';
import 'package:elderly_app/screens/relatives/edit_relatives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:elderly_app/others/notification_service.dart';

late NotificationAppLaunchDetails notificationAppLaunchDetails;
late NotificationService notificationService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationService = NotificationService();
  notificationService.initialize();
  notificationAppLaunchDetails = await notificationService.notificationDetails();

  setupLocator();
  await FlutterDownloader.initialize(debug: false);
  runApp(const ElderlyApp());
}

class ElderlyApp extends StatelessWidget {
  const ElderlyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    precacheImage(
      const AssetImage('lib/resources/images/loadingimage.jpg'),
      context,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Care',
      initialRoute: LoadingScreen.id,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        HeartRateScreen.id: (context) => const HeartRateScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
        MedicineReminder.id: (context) => const MedicineReminder(),
        LoadingScreen.id: (context) => LoadingScreen(auth: Auth()),
        ContactScreen.id: (context) => const ContactScreen(),
        LoginScreen.id: (context) => LoginScreen(auth: Auth()),
        ProfileEdit.id: (context) => const ProfileEdit(),
        NoteList.id: (context) => const NoteList(),
        // A dummy Reminder instance is created inline.
        ReminderDetail.id: (context) =>
            ReminderDetail(Reminder('', '', '', 0, false), ''),
        NearbyHospitalScreen.id: (context) => const NearbyHospitalScreen(),
        InitialSetupScreen.id: (context) => const InitialSetupScreen(),
        EditRelativesScreen.id: (context) => EditRelativesScreen(''),
        AppoinmentReminder.id: (context) => const AppoinmentReminder(),
        AppoinmentDetail.id: (context) => AppoinmentDetail(
          Appoinment('', '', '', '', 999999, false),
          '',
        ),
        ViewDocuments.id: (context) => const ViewDocuments(),
        AddDocuments.id: (context) => const AddDocuments(),
        ImageLabel.id: (context) => const ImageLabel(),
        AppoinmentDecision.id: (context) =>
            AppoinmentDecision(Appoinment('', '', '', '', 999999, false)),
        OnBoardingScreen.id: (context) => const OnBoardingScreen(),
      },
      theme: ThemeData(
        fontFamily: GoogleFonts.lato().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
        textTheme: TextTheme().apply(
          fontFamily: GoogleFonts.lato().fontFamily,
        ),
      ),
    );
  }
}
