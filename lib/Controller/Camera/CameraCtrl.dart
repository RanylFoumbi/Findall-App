//import 'package:flutter/material.dart';
//import 'dart:async';
//import 'package:image_picker/image_picker.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:uuid/uuid.dart';
//
//class CameraScreen extends StatefulWidget{
//
//  @override
//  CameraScreenState createState() => CameraScreenState();
//}
//
//
//class CameraScreenState extends State<CameraScreen>{
//
//
//  var images;
//  List imageList = [];
//  List urlList = [];
//
//  uploadImage(image) async{
//    var url;
//      var uuid = new Uuid();
//      var id = uuid.v4();
//      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("foundObjectImages/${id.toString()}.jpg");
//      final StorageUploadTask task = firebaseStorageRef.putFile(image);
//      var dowurl = await (await task.onComplete).ref.getDownloadURL();
//      url = dowurl.toString();
//
//    return url;
//   }
//
//
//  getImageFromGallery(context) async{
//    Navigator.of(context).pop();
//    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
//
//    setState(() {
//      imageList.add(picture);
//    });
//
//  }
//
//  getImageFromCamera(context) async{
//    Navigator.of(context).pop();
//    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
//
//    setState(() {
//      imageList.add(picture);
//    });
//
//  }
//
//
//Future Dialog(BuildContext context) async {
//  return  showDialog(
//      context: context,
//      barrierDismissible: true,
//      builder: (BuildContext context) {
//        return SimpleDialog(
//          title: const Text('Make a choice',style: TextStyle(fontSize: 17)),
//          children: <Widget>[
//            SimpleDialogOption(
//              onPressed: () {
//                getImageFromCamera(context);
//              },
//              child: const Text('From Camera'),
//            ),
//            SimpleDialogOption(
//              onPressed: () {
//                getImageFromGallery(context);
//              },
//              child: const Text('From Gallery'),
//            ),
//
//          ],
//        );
//      });
//}
//
//
//  Widget displayImage(){
//      var rowImage = Row(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//        children: <Widget>[
//
//        ],
//      );
//    if(imageList.length == 0){
//      return Text("Select images.",style: TextStyle(color: Colors.black));
//    }
//    else{
//      for(var i=0; i<imageList.length; i++){
//        rowImage.children.add(
//          Image.file(
//            imageList[i],
//            width: 60,
//            height: 80,
//            fit: BoxFit.cover
//          )
//        );
//      }
//
//    }
//    return Row(children: <Widget>[rowImage],mainAxisAlignment: MainAxisAlignment.spaceEvenly,);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return Card(
////      color: Colors.yellow,
//      child: Row(
//        children: <Widget>[
//          SizedBox(height: 110, width: 0),
//          imageList.length < 4 ?
//          IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.pink,size: 30), onPressed: (){
//            Dialog(context);
//          })
//          :
//          Text("button",style: TextStyle(color: Colors.white)),
//
//        displayImage(),
//        ],
//      ),
//
//    );
//  }
//}