import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elderly_app/models/image.dart';
import 'package:elderly_app/screens/document/add_documents_screen.dart';
import 'package:elderly_app/screens/document/document_detail_screen.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewDocuments extends StatefulWidget {
  static const String id = 'View_Documents_Screen';

  @override
  _ViewDocumentsState createState() => _ViewDocumentsState();
}

class _ViewDocumentsState extends State<ViewDocuments> {
  late TextEditingController nameController;
  String? userId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    getCurrentUser();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;
    });
  }

  List<Widget> addImages(List<ImageClass> imageList) {
    return imageList.map((image) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentDetail(image),
            ),
          );
        },
        child: Hero(
          tag: image.name,
          child: Container(
            margin: EdgeInsets.only(bottom: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(image.url),
              ),
            ),
            child: SizedBox(
              width: 250,
              height: 250,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(99),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 250,
                  height: 35,
                  child: Center(
                    child: Text(
                      image.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: ElderlyAppBar(),
      body: ListView(
        children: <Widget>[
          StreamBuilder<DocumentSnapshot>(
            stream: userId != null
                ? FirebaseFirestore.instance
                    .collection('documents')
                    .doc(userId)
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Please wait.'),
                    ),
                    CircularProgressIndicator(),
                  ],
                );
              }

              if (snapshot.hasData && snapshot.data?.data() != null) {
                ImageModel images = ImageModel();
                List<ImageClass> imageList =
                    images.getAllImages(snapshot.data!.data() as Map<String, dynamic>);
                List<ImageClass> searchImageList = imageList;

                if (nameController.text.isNotEmpty) {
                  searchImageList = images.searchImages(nameController.text);
                }

                List<Widget> imageWidgets = addImages(searchImageList);

                return Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Color(0xff42495D),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                        ),
                      ),
                      child: TextField(
                        onSubmitted: (v) {
                          setState(() {
                            searchImageList = images.searchImages(v);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          hintText: 'Search for files',
                        ),
                        controller: nameController,
                        onChanged: (v) {
                          setState(() {
                            searchImageList = images.searchImages(v);
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        searchImageList.isNotEmpty
                            ? 'Documents'
                            : 'Files not Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Column(
                      children: imageWidgets,
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No Documents added'),
                    ),
                    Text('Add now.'),
                  ],
                );
              }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddDocuments.id);
        },
        elevation: 2,
        backgroundColor: Colors.cyan,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade200,
        elevation: 2,
        notchMargin: 2,
        child: Container(
          height: 56,
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text('Upload Files'),
            ),
          ),
        ),
        shape: CircularNotchedRectangle(),
      ),
    );
  }
}
