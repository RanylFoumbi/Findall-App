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
import 'package:page_transition/page_transition.dart';
import 'package:findall/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CreateNewFound extends StatefulWidget{

  @override
  CreateNewFoundState createState() => CreateNewFoundState();
}


class CreateNewFoundState extends State<CreateNewFound>{

  LocalStorage _storage = LocalStorage('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var otherObjectController = TextEditingController();
  var otherTownController = TextEditingController();
  var quarterController = TextEditingController();
  var descriptionController = TextEditingController();
  var phoneController = TextEditingController();
  var nameController = TextEditingController();
  bool _isLoadingImg = false;
  bool _isLoading = false;
  List imageList = [];
  List urlList = [];
  String objectName;
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
        'date' : DateFormat("EEE d MMM yyyy Hm").format(time),
        'images': urlList,
      };

      print(imageList);

      _storage.setItem('userphone', founderPhone);
      _storage.setItem('username', founderName);
      _storage.setItem('userimage', founderImage);

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
            PageTransition(
                type: PageTransitionType.fade,
                child: FoundList()
            )
        );
        Toast.show("objet publié avec succès.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        print("Objet publié avec succès");
      }
      else {

        // If that response was not OK, throw an error.
        var errorData = json.decode(response.body);
        var error = errorData["error"]["message"];
        if(error == "EMAIL_EXISTS") {
          setState(() {
            _isLoading = true;
          });
//          Toast.show("Cette addresse Email existe déja.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
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
          Toast.show("Une érreur s'est produite, veuillez reéssayer.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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

      noInternet(context, "Veuillez vérifier votre connexion internet, puis réessayez");
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
      Toast.show("Réessayer.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
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
        urlList.insert(i,url);
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
    if(picture == null){
      Toast.show("Vous devez télécharger au moins une image avant de publier.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
    }

  }

  getImageFromCamera(context) async{
    Navigator.of(context).pop();
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageList.add(picture);
    });
    if(picture == null){
      Toast.show("Vous devez télécharger au moins une image avant de publier.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);
    }
  }

  Future Dialog(BuildContext context) async {
    return  showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Importer la photo depuis',style: TextStyle(fontSize: 17)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  getImageFromCamera(context);
                },
                child: const Text('la caméra'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  getImageFromGallery(context);
                },
                child: const Text('la gallerie'),
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
      return Text("Télécharger des images de l'objet.",style: TextStyle(color: Colors.black));
    }
    else{
      for(var i=0; i<imageList.length; i++){
        imageList==null
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
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });

      uploadImage().then((urlList) {
          publishFound(context, objectName, town, quarter, description, urlList,founderName,founderPhone,founderImage);
      });

    }
    else{
      Toast.show("Assurez-vous d'avoir rempli tout le formulaire, puis réessayez.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final topBar = new AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 1.0,
      leading: new IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.deepPurple,size: 40),
          onPressed: (){
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade,
                    child: Home()
                )
            );
          }
      ),
      title: SizedBox(
        height: 40.0 , child: Image.asset('assets/images/icon_findall.png', width: 10,height: 15),width: 60,
      ),
    );

    final objectTitle =  new Container(
          width: width/1.15,
          padding: EdgeInsets.only(left: 6.5,right: 6.5),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text("Quel objet avez-vous trouvé? S'il vous plaît choisissez l'option 'Autre...' si l'object ne figure pas.",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),
                    textAlign: TextAlign.center,
                  ),
              )
            ],
          )
    );

    final objectNames =  new Container(
        width: width/1.2,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Color(0xffdcdcdc))),
        padding: EdgeInsets.only(left: 25.0, right: 7.0),
        child: DropdownButtonHideUnderline(
          child: new DropdownButton<String>(
              iconEnabledColor: Color(0xffdcdcdc),
              iconSize: 40,
              style: TextStyle(fontWeight: FontWeight.w700,color: Colors.black),
              hint:  objectName == null ?
              Text(objectName = "Carte national d'identité")
                  :
              Text(objectName),
              onChanged: (String changedValue) {
                objectName = changedValue;
                setState(() {
                  objectName;
                });
              },
              value: objectName,
              items: <String>[ 'Actes de naissance',"Carte national d'identité", 'Dilplômes', 'Passe port','Relevé de note','Téléphone portable','Autre...' ]
                  .map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value),
                );
              }).toList()),
        )
    );


    final otherObject = TextFormField(
      controller: otherObjectController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: "Autre type d'objet",
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        prefixIcon: Icon(
            Icons.devices_other,
            color: Color(0xffdcd3d3)
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color(0xffdcdcdc)
            ),
            borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );


    final townTitle =  new Container(
        width: width/1.15,
        padding: EdgeInsets.only(left: 6.5,right: 6.5),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text("Où? S'il vous plaît choisissez l'option 'Autre...' si la ville ne figure pas.",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400
                  ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        )
    );

    final town = new Container(
      width: width/1.2,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Color(0xffdcdcdc))),
      padding: EdgeInsets.only(left: 25.0, right: 7.0),
      child: DropdownButtonHideUnderline(
          child: new DropdownButton<String>(
            iconEnabledColor: Color(0xffdcdcdc),
            iconSize: 40,
            style: TextStyle(fontWeight: FontWeight.w700,color: Colors.black),
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
          items: <String>['Bafoussam','Bamenda', 'Bertoua', 'Buéa', 'Douala','Ebolowa', 'Garoua', 'Maroua', 'Ngaoundéré',"Yaoundé",'Autre...']
              .map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList()),
      )
    );

    final otherTown = TextFormField(
      controller: otherTownController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Autre ville**',
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        prefixIcon: Icon(
            Icons.location_city,
            color: Color(0xffdcd3d3)
        ),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xffdcdcdc)),
            borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );

    final quarter = TextFormField(
      controller: quarterController,
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (String value){
        if(value.isEmpty ){
            return "Ce champ ne peut pas être vide";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: 'Dans quel quartier? **',
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        prefixIcon: Icon(Icons.home,color: Color(0xffdcdcdc)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),borderSide: BorderSide(color: Color(0xffdcdcdc),))
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
          return "Ce champ ne peut pas être vide";
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        hintText: "Entrez une petite description de l'objet ...**",
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        alignLabelWithHint: true,
        contentPadding: EdgeInsets.only(top: 10,right: 3, left: 10, bottom: 2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),borderSide: BorderSide(color: Color(0xffdcdcdc),))
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
          IconButton(icon: Icon(Icons.file_upload, color: Colors.pink,size: 30), onPressed: (){
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
        hintText: 'Votre nom**',
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        prefixIcon: Icon(Icons.person,color: Color(0xffdcdcdc)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),borderSide: BorderSide(color: Color(0xffdcdcdc),))
      ),
      validator: (String value){
        if(value.isEmpty){
          return "Ce champ ne peut pas être vide";
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
        hintText: 'Votre numéro de tel**',
        hintStyle: TextStyle(fontSize: 13,fontStyle: FontStyle.italic),
        prefixIcon: Icon(Icons.phone,color: Color(0xffdcdcdc)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),borderSide: BorderSide(color: Color(0xffdcdcdc),))
      ),
      validator: (String value){
        if(value.isEmpty){
          return "Ce champ ne peut pas être vide";
        }else{
          return null;
        }
      },
    );

    final founderImge = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Votre photo'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRRect(
              borderRadius: new BorderRadius.circular(50.0),
              child: _image == null
                  ?
              ClipRRect(borderRadius: new BorderRadius.circular(50),clipBehavior: Clip.antiAlias, child: SpinKitRipple(color: Colors.pink,size: 80),)
                  :
              CachedNetworkImage(
                  height: 80,
                  width: 00,
                  imageUrl: _image,
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.noRepeat,
                  placeholder: (context, url) => SpinKitFadingCircle(color: Colors.deepPurple,size: 70),
                  errorWidget: (context, url, error) => new Icon(Icons.error,color: Colors.deepPurple,size: 35)
              )
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


    final FounderInfo = Container(
      margin:  EdgeInsets.only(left:5.0,right: 5.0),
      padding:  EdgeInsets.only(top: height/35,left: width/18,right: width/18,bottom: height/35),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffeaeff2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          SizedBox(height: height/60),
          founderName,
          SizedBox(height: height/35),
          founderphone,
          SizedBox(height: height/35),
          founderImge,
        ],
      ),
    );


    final publish = !_isLoading
        ?
    FloatingActionButton.extended(
      icon: Icon(Icons.public),
      label: Text('Publier'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Colors.pink,
      heroTag: "publish button",
      onPressed: () {

        objectName == 'Autre...'
                              ?
                          objectName = otherObjectController.text
                              :
                          objectName = objectName;

        townName == 'Autre...'
                              ?
                          townName = otherTownController.text
                              :
                          townName = townName;

        validateSaveAndPublish(_formKey,context,objectName,townName,quarterController.text,descriptionController.text,nameController.text,phoneController.text,_image);
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
                padding: EdgeInsets.only(left: 24.0, right: 24.0,bottom: 40),
                children: <Widget>[
                  SizedBox(height: 20.0),
                  objectTitle,
                  SizedBox(height: 10.0),
                  objectNames,
                  objectName == 'Autre...'
                      ?
                  SizedBox(height: 10.0)
                      :
                  SizedBox(height: 0.0),
                  objectName == 'Autre...'
                      ?
                  otherObject
                      :
                  SizedBox(height: 0.0),
                  SizedBox(height: 15.0),
                  townTitle,
                  SizedBox(height: 10.0),
                  town,
                  townName == 'Autre...'
                      ?
                  SizedBox(height: 10.0)
                      :
                  SizedBox(height: 0.0),
                  townName == 'Autre...'
                      ?
                  otherTown
                      :
                  SizedBox(height: 0.0),
                  SizedBox(height: 10.0),
                  quarter,
                  SizedBox(height: 10.0),
                  description,
                  SizedBox(height: 10.0),
                  camera,
                  SizedBox(height: 10.0),
                  FounderInfo,
                  SizedBox(height: 15.0),
                  imageList.length == 0
                                  ?
                                  Text('Veuillez remplir le formulaire en entier.',textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),)
                                  :
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
              PageTransition(
                  type: PageTransitionType.upToDown,
                  child: Home()
              )
          );

        }
    );
  }


}
















