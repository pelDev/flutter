import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firebase Upload Demo",
      home: Upload(),

    );
  }
}

// The User Interface

class Upload extends StatefulWidget {

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  File _imageFile;
  final picker = ImagePicker();
  bool isUploaded = false;
  String _url;
  double percent;
  bool isInProgress = false;

  Future getImage (bool isCamera) async {
    var image;
    if(isCamera) {
      image = await picker.getImage(source: ImageSource.camera);
    } else {
      image = await picker.getImage(source: ImageSource.gallery);
    }
    setState(() {
      _imageFile = File(image.path);
    });
  }

  Future uploadImage() async {
    StorageReference reference = FirebaseStorage.instance.ref().child('myimage.jpg');
    StorageUploadTask uploadTask = reference.putFile(_imageFile);
    

    if (uploadTask.isInProgress) {
      uploadTask.events.listen((event) {
        double percentage = (event.snapshot.bytesTransferred.toDouble()
                                    / event.snapshot.totalByteCount.toDouble());
        setState(() {
          isInProgress = true;
          percent = percentage;
        });
        print(percent.toString());
      });

      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      _url = await taskSnapshot.ref.getDownloadURL();
      print('Download URL ' + _url.toString());
    }

    

    

  setState(() {
    isInProgress = false;
  });
  }

  @override
  Widget build(BuildContext context) {
    return isInProgress == true ? Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget> [
          
          Center(
            child: new CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 5.0,
                    percent: percent,
                    center: new Text("100%"),
                    progressColor: Colors.red,
                  ),
          ),
          Text('Upload Progress ' + (100 * percent).toString() + '%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ), 
        ],
      ),
    ) : Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Upload Image to Firebase'),
        backgroundColor: Colors.redAccent,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0,),
              Text('Upload Image From,', style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
              ),),
              SizedBox(height: 10.0,),

              RaisedButton(
                color: Colors.red,
                child: Text(
                  'Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  getImage(true);
                },
              ),

              RaisedButton(
                color: Colors.red,
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  getImage(false);
                },
              ),
              SizedBox(height: 10.0),
              Container(
                child: _imageFile == null ?
                Text('No Image Selected!',
                style: TextStyle(
                  color: Colors.red,
                ),) :
                  Container(
                  child: Image.file(_imageFile),
                ),
              ),
              SizedBox(height: 10.0,),

              Container(
                child: _imageFile == null ? Container() :

                RaisedButton(
                  color: Colors.red,
                  child: Text(
                    'Upload to Firebase',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    uploadImage();
                  },
                ),
              ),

              Container(
                child: isUploaded == false ? Container() : Container(child: Text('Uploaded', style: TextStyle(color: Colors.white))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
