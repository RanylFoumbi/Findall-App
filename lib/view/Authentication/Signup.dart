 //it allows us to convert our json to a list
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:findall/view/Found/CreateNewFoundPage.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:localstorage/localstorage.dart';


class SignupPage extends StatefulWidget {

  @override
  _SignupPageState createState() => new _SignupPageState();

}

 const API_KEY = 'AIzaSyDNJHgmmiEwJUY4XXflUhSNL0jfKC0aanI';

class _SignupPageState extends State<SignupPage> {

  LocalStorage storage = new LocalStorage('userdata');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  bool _isHidden = true;
  bool _isLoading = false;
  var _image;



  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(image);
    setState(() {
      _image = image;
    });
  }


  uploadImage(image) async{
    var url;
    var uuid = new Uuid();
    var id = uuid.v4();
      final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("foundObjectImages/${id.toString()}.jpg");
      final StorageUploadTask task = firebaseStorageRef.putFile(image);
      var dowurl = await (await task.onComplete).ref.getDownloadURL();
      url = dowurl.toString();

    return url;
  }


  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }


  void onCreateUser(context, String emailOrName, String name, String password, String phoneNumber, imageUrl) async {
    var url ='https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=$API_KEY';

    try {

        Map data = {
          'email' : emailOrName,
          'password' : password,
          'name' : name,
          'phone' : phoneNumber,
          'image': imageUrl,
          'returnSecureToken': true,
        };

        setState(() {
          _isLoading = true;
        });

      var response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(data));


      if (response.statusCode == 200) {

          storage.setItem('user', response.body);
          setState(() {
            _isLoading = false;
          });
          // Successfull create.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewFound(),
            ),
          );
          Toast.show("Compte créé avec succès.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
          print("Succesfful register");
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
            setState(() {
              _isLoading = false;
            });
            print("Adresse Email existante.");
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


  void validateAndSave(_formKey,context,emailOrName, name, password, phoneNumber,image){

    if (_formKey.currentState.validate()) {

      _formKey.currentState.save();

        image == null ?
          Toast.show("Ajoutez une photo de profil.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM)
        :
          uploadImage(image).then((imageUrl) {
             onCreateUser(context, emailOrName, name, password, phoneNumber, imageUrl);
          });

    }
    else{
    }
  }


  @override
  Widget build(BuildContext context) {

    final facebookButton = FlatButton.icon(
      color: Colors.blue[900],
      onPressed: (){},
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      icon: Image.asset('assets/images/facebook.png', width: 20,height: 20,),
      label: Text(
          'with Facebook',
          style: TextStyle(fontSize: 15,color: Colors.white)
      ),
    );

    final googleButton = FlatButton.icon(
      color: Colors.red[700],
      onPressed: (){},
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(13.0)),
      icon: Image.asset('assets/images/google.jpg', width: 20,height: 20,),
      label: Text(
          'with Google',
          style: TextStyle(fontSize: 15,color: Colors.white)
      ),
    );

    final rapidAuth = Row(

      children: <Widget>[
        facebookButton,
        SizedBox(width: 20),
        googleButton
      ],
    );


    return Scaffold(
      backgroundColor: Colors.white,
      body:Container(
          child: Builder(
              builder: (context) =>Form(
                key: _formKey,
                autovalidate: false,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 24.0, right: 24.0),
                  children: <Widget>[

                    SizedBox(height: 20.0),

                    new TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.email),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
                      ),
                      validator: (String value){
                        RegExp emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if(emailValid.hasMatch(value) == true){
                          return null;
                        } else if(value.isEmpty ){
                          return "This field must not be empty";
                        }else{
                          return "Must be an email address";
                        }
                      },

                    ),


                    SizedBox(height: 20.0),

                    new TextFormField(
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
                      ),
                      validator: (String value){
                        if(value.isEmpty){
                          return "This field must not be empty";
                        }else if(value.length < 6){
                          return "Must be at least 6 caracters";
                        }else{
                          return null;
                        }
                      },
                    ),

                    SizedBox(height: 20.0),

                    new TextFormField(
                      autofocus: false,
                      obscureText: _isHidden,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: 'password',
                        prefixIcon: Icon(Icons.lock),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
                        suffixIcon: IconButton(
                          onPressed: _toggleVisibility,
                          icon: !_isHidden ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                        )
                      ),
                      validator: (String value){
                        if(value.isEmpty ){
                          return "This field must not be empty";
                        }
                       else if(value.length < 6){
                          return "Must be at least 6 caracters";
                        }else{
                          return null;
                        }
                      },
                    ),


                    SizedBox(height: 20.0),

                    new TextFormField(
                      keyboardType: TextInputType.phone,
                      autofocus: false,
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: 'Phone',
                        prefixIcon: Icon(Icons.phone),
                        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.0)),
                      ),
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      validator: (String value){
                        if(value.isEmpty){
                          return "This field must not be empty";
                        }else if(value.length < 6){
                          return "Must be at least 6 caracters";
                        }else{
                          return null;
                        }
                      },
                    ),

                    SizedBox(height: 10.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('Founder Image'),
                        ClipRRect(
                          borderRadius: new BorderRadius.circular(50.0),
                          child: _image == null
                              ? null
                              : Image.file(
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
                            )),
                      ],
                    ),

                    SizedBox(height: 0.0),

                    new Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(13.0),
                        elevation: 5.0,
                        child:!_isLoading
                            ?  new FloatingActionButton.extended(
                          label: Text('Signup'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)
                          ),
                          backgroundColor: Colors.pink,
                          heroTag: "signup button",
                          onPressed: (){
                            // Validate returns true if the form is valid, or false
                            // otherwise.

                            validateAndSave(_formKey,context,emailController.text,nameController.text, passwordController.text,phoneController.text, _image);

                          },
                        )
                        :
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                                strokeWidth: 3, backgroundColor: Colors.white),
                          ],
                        )
                      ),
                    ),

                  SizedBox(height: 10.0),
                  rapidAuth,
                  ],
                ),
              ),

          )
      )

    );
  }
}