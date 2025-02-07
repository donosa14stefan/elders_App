import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_app/screens/document/view_documents_screen.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class AddDocuments extends StatefulWidget {
  static const String id = 'Add_Documents_Screen';
  const AddDocuments({Key? key}) : super(key: key);

  @override
  _AddDocumentsState createState() => _AddDocumentsState();
}

class _AddDocumentsState extends State<AddDocuments> {
  late TextEditingController nameController;
  late bool imageLoaded;
  late bool imageUploading;
  File? _image;
  final ImagePicker picker = ImagePicker();
  late String userId;
  late Map<String, dynamic> allImages;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    imageLoaded = false;
    imageUploading = false;
    allImages = {};
    getCurrentUser();
  }

  Future<void> getImage(String method) async {
    XFile? pickedFile;
    if (method == 'camera') {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        imageLoaded = true;
      });
    }
  }

  Future<void> getAllImageData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('documents')
        .doc(userId)
        .get();
    setState(() {
      allImages = snapshot.data() ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: const ElderlyAppBar(),
      body: !imageUploading
          ? ListView(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      decoration: const BoxDecoration(
                        color: Color(0xff42495D),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          const FaIcon(
                            FontAwesomeIcons.cloudUploadAlt,
                            color: Colors.white,
                            size: 90,
                          ),
                          const Text(
                            'Upload Documents',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              'Add your documents here and have them everywhere you go.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -35,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await getImage('camera');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 35),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          primary: Colors.amber.shade700,
                        ),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        label: const Text(
                          'Use Camera',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'OR',
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await getImage('gallery');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(
                        Icons.photo_library,
                        size: 40,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select from Gallery',
                        style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                            fontSize: 19),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                imageLoaded
                    ? Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              style: const TextStyle(fontSize: 18),
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(5),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                  helperText: 'Document Name',
                                  hintText: ' Add Name to search easily'),
                              controller: nameController,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isEmpty) {
                                nameController.value =
                                    const TextEditingValue(text: 'Document');
                              }
                              await uploadFile(nameController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text(
                              'Upload Image',
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Text(
                            'Add Image to start upload.',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Uploading Document'),
                  ),
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
    );
  }

  Future<void> uploadFile(String name) async {
    setState(() {
      imageUploading = true;
    });
    await getAllImageData();
    if (!allImages.containsKey(name)) {
      String fileName = name;
      String imageUrl;
      Reference reference =
          FirebaseStorage.instance.ref().child('$userId/$fileName');
      UploadTask uploadTask = reference.putFile(_image!);
      try {
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
        await updateData(fileName, imageUrl);
        Navigator.pop(context);
      } catch (err) {
        showDialog(
            context: context,
            builder: (context) {
              return const Dialog(
                child: Text('Upload Failed'),
              );
            });
      }
    } else {
      setState(() {
        imageUploading = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return const Dialog(
              child: Text('Document with same name exists.'),
            );
          });
    }
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Future<void> updateData(String name, String value) async {
    allImages[name] = value;
    await FirebaseFirestore.instance
        .collection('documents')
        .doc(userId)
        .update(allImages);
    setState(() {
      imageUploading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
