import 'package:flutter/material.dart';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:findall/view/Found/FoundList.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:findall/view/Home/Home.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateNewFound extends StatefulWidget{

  @override
  CreateNewFoundState createState() => CreateNewFoundState();
}


class CreateNewFoundState extends State<CreateNewFound>{

  LocalStorage storage = LocalStorage('userphoneNumber');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var objectNameController = TextEditingController();
  var otherFieldController = TextEditingController();
  var townController = TextEditingController();
  var quaterController = TextEditingController();
  var descriptionController = TextEditingController();
  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  bool _isLoadingImg = false;
  bool _isLoading = false;
  List imageList = [];
  List urlList = [];
  String objetName;
  String townName;
  var time = DateTime.now().toUtc();
  var _image;


  @override
  void initState() {
    super.initState();
  }



  void publishFound(context, String objectName, String town, String quarter, String description, List urlList,String founderName,String founderPhone, founderImage) async {
    var url ='https://testfinder-5bdda.firebaseio.com/foundedObject.json';

    try {

      Map data = {
        'objectName' : objectName,
        'town' : town,
        'quarter': quarter,
        'description': description,
        'founder': founderName,
        'fouderphone': founderPhone,
        'foundImage': founderImage,
        'date' : DateFormat("EEE d MMM yyyy Hms").format(time),
        'images': urlList,
      };
      print(imageList);

      setState(() {
        _isLoading = true;
      });

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(data));

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {

        // Successfull register supplier.
        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoundList()),
        );
        Toast.show("objet publié avec succès.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        print("objet publié avec succès");
      }
      else {

        // If that response was not OK, throw an error.
        var errorData = json.decode(response.body);
        var error = errorData["error"]["message"];
        if(error == "EMAIL_EXISTS") {
          setState(() {
            _isLoading = true;
          });
          Toast.show("Cette addresse Email existe déja.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
          print("Adresse Email existante.");
          setState(() {
            _isLoading = false;
          });
        } else {
          // Une autre Erreur
          setState(() {
            _isLoading = true;
          });
          print("Une érreur s'est produite, veuillez reéssayer.");
          Toast.show("Une érreur s'est produite, veuillez reéssayer.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = true;
      });
      print("Pas d'internet.");
      Toast.show("veuillez vérifier votre connexion internet.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      setState(() {
        _isLoading = false;
      });
    }

  }


  uploadFounderImage(image) async{
    var url;
    var uuid = new Uuid();
    var id = uuid.v4();
      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("founderImages/${id.toString()}.jpg");
      final StorageUploadTask task = firebaseStorageRef.putFile(image);
      var dowurl = await (await task.onComplete).ref.getDownloadURL();
      url = dowurl.toString();
    return url;
  }


   getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _isLoadingImg = true;
    });
    uploadFounderImage(image)
        .then((url){
      setState(() {
        _isLoadingImg = false;
        _image = url;
      });
    }).catchError((e){
      print(e);
      Toast.show("veuillez réessayer.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    });

  }


  uploadImage() async{
    var url;
    var uuid = new Uuid();
    var id = uuid.v4();
    for(var i=0; i<imageList.length; i++){
      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("foundObjectImages/${id.toString()}.jpg");
      final StorageUploadTask task = firebaseStorageRef.putFile(imageList[i]);
      var dowurl = await (await task.onComplete).ref.getDownloadURL();
      url = dowurl.toString();
      setState(() {
        urlList.add(url);
      });
    }
    print(urlList);
    return urlList;
  }

  getImageFromGallery(context) async{
    Navigator.of(context).pop();
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageList.add(picture);
    });

  }

  getImageFromCamera(context) async{
    Navigator.of(context).pop();
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageList.add(picture);
    });

  }

  Future Dialog(BuildContext context) async {
    return  showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Make a choice',style: TextStyle(fontSize: 17)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  getImageFromCamera(context);
                },
                child: const Text('From Camera'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  getImageFromGallery(context);
                },
                child: const Text('From Gallery'),
              ),

            ],
          );
        });
  }



  Widget displayImage(){
    var rowImage = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[

      ],
    );
    if(imageList.length == 0){
      return Text("Pick images.",style: TextStyle(color: Colors.black));
    }
    else{
      for(var i=0; i<imageList.length; i++){
        imageList[i]==null
            ?
        rowImage
            :
        rowImage.children.add(
            Image.file(
                imageList[i],
                width: 60,
                height: 80,
                fit: BoxFit.cover
            )
        );
      }

    }
    return Row(children: <Widget>[rowImage],mainAxisAlignment: MainAxisAlignment.spaceEvenly,);
  }

  void validateSaveAndPublish(_formKey,context,objectName,town,quarter,description,founderName,founderPhone,founderImage){

    if (_formKey.currentState.validate()) {
      imageList.isEmpty
          ?
            Toast.show("veuillez piquer des images et réessayer.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM)
          :
          _formKey.currentState.save();
          setState(() {
            _isLoading = true;
          });

          uploadImage().then((urlList) {
            publishFound(context, objectName, town, quarter, description, urlList,founderName,founderPhone,founderImage);
          });

    }
    else{
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final topBar = new AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 1.0,
      leading: new IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.deepPurple,size: 40),
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          }
      ),
      title: SizedBox(
          height: 40.0 , child: Image.asset('assets/images/icon_findall.png', width: 10,height: 15),width: 60,
      ),
    );



    final objectNames =  new ListTile(
      title: const Text('Object name'),
      contentPadding: EdgeInsets.all(2),
      trailing: new DropdownButton<String>(
          iconSize: 40,
         style: TextStyle(fontWeight: FontWeight.w900,color: Colors.black),
          hint:  objetName == null ?
                  Text(objetName = "Carte national d'identité")
                :
                 Text(objetName),
          onChanged: (String changedValue) {
            objetName = changedValue;
            setState(() {
              objetName;
            });
          },
          value: objetName,
          items: <String>["Carte national d'identité",'Mobile phone', 'Passe port', 'Relevé de note','Autre.....']
              .map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList()),
    );

    final town = new ListTile(
      title: const Text('Town'),
      contentPadding: EdgeInsets.all(2),
      trailing: new DropdownButton<String>(
        iconSize: 40,
          style: TextStyle(fontWeight: FontWeight.w900,color: Colors.black),
          hint:  townName == null ?
                Text(townName = "Yaoundé")
              :
                Text(townName),
          onChanged: (String changedValue) {
            townName = changedValue;
            setState(() {
              townName;
            });
          },
          value: townName,
          items: <String>["Yaoundé", 'Douala', 'Bertoua','Bamenda', 'Buéa', 'Bafoussam','Ngaoundéré', 'Maroua', 'Garoua','Ebolowa']
              .map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList()),
    );



    final quater = TextFormField(
      controller: quaterController,
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (String value){
        if(value.isEmpty ){
          return "This field must not be empty";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: 'Quater',
        prefixIcon: Icon(Icons.home),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final description = TextFormField(
      controller: descriptionController,
      keyboardType: TextInputType.multiline,
      autocorrect: true,
      maxLines: 5,
      autofocus: false,
      validator: (String value){
        if(value.isEmpty ){
          return "This field must not be empty";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: 'enter a small description...',
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.only(top: 10,right: 3, left: 10, bottom: 2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final camera = Card(
      child: Row(
        children: <Widget>[
          SizedBox(height: 110, width: 0),
          _isLoading ?
              Text("butoi",style: TextStyle(color: Colors.white))
            :
              imageList.length < 4 ?
              IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.pink,size: 30), onPressed: (){
                Dialog(context);
              })
                  :
              Text("butoi",style: TextStyle(color: Colors.white)),

          displayImage(),
        ],
      ),

    );

    final founderName = new TextFormField(
        keyboardType: TextInputType.text,
        autofocus: false,
        controller: nameController,
        decoration: InputDecoration(
          hintText: 'Founder name',
          prefixIcon: Icon(Icons.person),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        validator: (String value){
          if(value.isEmpty){
            return "This field must not be empty";
          }else{
            return null;
          }
        },
     );

    final founderphone = new TextFormField(
      keyboardType: TextInputType.phone,
      autofocus: false,
      controller: phoneController,
      decoration: InputDecoration(
        hintText: 'Founder phone',
        prefixIcon: Icon(Icons.phone),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (String value){
        if(value.isEmpty){
          return "This field must not be empty";
        }else{
          return null;
        }
      },
    );

    final founderImge = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
              Text('Founder image'),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: new BorderRadius.circular(50.0),
                    child: _image == null
                        ?
                    ClipRRect(borderRadius: new BorderRadius.circular(50),clipBehavior: Clip.antiAlias,child:  SpinKitRipple(color: Colors.pink,size: 80),)
                        :
                    _isLoadingImg
                                ?
                                SpinKitHourGlass(color: Colors.deepPurple,size: 30)
                                :
                                  Image.network(
                                    _image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 0),
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: InkWell(
                        child: CircleAvatar(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.pink,
                          ),
                          radius: 20,
                          backgroundColor: Colors.transparent,
                        ),
                        onTap: getImage,
                      )
                  ),
                ],
              )
      ],
    );


    final publish = !_isLoading
                                ?
                                 FloatingActionButton.extended(
                                  icon: Icon(Icons.public),
                                  label: Text('publish'),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)
                                  ),
                                  backgroundColor: Colors.pink,
                                  heroTag: "publish button",
                                  onPressed: () {
                                    validateSaveAndPublish(_formKey,context,objetName,townName,quaterController.text,descriptionController.text,nameController.text,phoneController.text,_image);
                                   },
                                  )
                              :
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SpinKitWave(color: Colors.deepPurple,size: 30),
                                ],
                               );


    return WillPopScope(
        child: Scaffold(
          appBar: topBar,
          body: Builder(
            builder: (context) =>Form(
              key: _formKey,
              autovalidate: false,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[

                  objectNames,
                  SizedBox(height: 10.0),
                  town,
                  SizedBox(height: 10.0),
                  quater,
                  SizedBox(height: 10.0),
                  description,
                  SizedBox(height: 10.0),

                  camera,
                  SizedBox(height: 10.0),
                  founderName,
                  SizedBox(height: 10.0),
                  founderphone,
                  SizedBox(height: 10.0),
                  founderImge,
                  SizedBox(height: 15.0),
                  publish,
                  SizedBox(height: 25.0),

                ],
              ),
            ),
          ),
        ),
        onWillPop: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Home()
              )
          );
        }
    );
  }
}
















