import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:findall/view/Found/CreateNewFoundPage.dart';
import 'package:toast/toast.dart';
import 'package:localstorage/localstorage.dart';
import 'SmsAuthPage.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => new _LoginPageState();

}

const API_KEY = 'AIzaSyDNJHgmmiEwJUY4XXflUhSNL0jfKC0aanI';


class _LoginPageState extends State<LoginPage> {

  final GlobalKey<FormState> _formkey = new GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isHidden = true;
  bool _isLoading = false;
  final LocalStorage storage = new LocalStorage('userdata');

  @override
  void initState() {
    super.initState();
  }


  void _toggleVisibility(){
    setState(() {
      _isHidden = !_isHidden;
    });
  }


  void onCreateUser(context, String emailOrName, String password) async {
    var url ='https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=$API_KEY';

    try {
      Map data = {
        'email' : emailOrName,
        'password' : password,
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
        Toast.show("connecté succès.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
        print("Succesfful Login");
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


  void validateAndSave(_formKey,context,emailOrName,password){

    if (_formKey.currentState.validate()) {

      _formKey.currentState.save();

      onCreateUser(context,emailOrName,password);

    }
    else{
    }
  }


  @override
  Widget build(BuildContext context) {

    final facebookButton = new Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Material(
            borderRadius: BorderRadius.circular(10.0),
            shadowColor: Colors.lightBlueAccent.shade100,
            elevation: 5.0,
            child:new FloatingActionButton.extended(
                label: Text('Se connecter avec Facebook',style: TextStyle(fontSize: 15,color: Colors.white)),
                icon: Image.asset('assets/images/facebook.png', width: 35,height: 35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                backgroundColor: Colors.blue[900],
                heroTag: " fb button",
                onPressed: (){
                  // Validate returns true if the form is valid, or false
                  // otherwise.

                })
        ));

    final googleButton = new Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Material(
            borderRadius: BorderRadius.circular(10.0),
            shadowColor: Colors.lightBlueAccent.shade100,
            elevation: 5.0,
            child: new FloatingActionButton.extended(
              label: Text('Se connecter avec Google'),
              icon: Image.asset('assets/images/google.jpg', width: 35,height: 35),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.red[700],
              heroTag: "google button",
              onPressed: (){
                // Validate returns true if the form is valid, or false
                // otherwise.

              },
            )
        )
    );



    final smsButton =  new FloatingActionButton.extended(
      label: Text('Se connecter avec un code sms'),
      icon: Icon(Icons.phone,color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      backgroundColor: Colors.deepPurple,
      heroTag: "signup button",
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SMSLoginPage(),
          ),
        );

      },
    );





    final forgotLabel = FlatButton(
      child: Text(
        'new account ?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {
      /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupPage()),
        );*/
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          child: Builder(
            builder: (context) =>Form(
              key: _formkey,
              autovalidate: false,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: <Widget>[

                  SizedBox(height: 30.0),

                  new TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    autofocus: false,
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email),
                      contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    validator: (String value){
                      RegExp emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if(value.isEmpty ){
                        return "This field must not be empty";
                      }
                      else if(emailValid.hasMatch(value)){
                        return null;
                      }else{
                        return "Must be an email address";
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
                      } else {
                        return null;
                      }
                    },
                  ),


                  SizedBox(height: 10.0),

                  new Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      shadowColor: Colors.lightBlueAccent.shade100,
                      elevation: 5.0,
                      child: !_isLoading
                        ?
                      new FloatingActionButton.extended(
                        label: Text('Login'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                    ),
                        backgroundColor: Colors.pink,
                        heroTag: "signin button",
                        onPressed: (){

                          validateAndSave(_formkey,context,emailController.text, passwordController.text);
                          // If the picture was taken, display it on a new screen.

                        },
                      )
                     : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                              strokeWidth: 3, backgroundColor: Colors.white),
                        ],
                      )
                    ),
                  ),
//                  SizedBox(height: 3.0),
                  smsButton,
                  SizedBox(height: 15.0),
                  facebookButton,
                  SizedBox(height: 15.0),
                  googleButton,
                  SizedBox(height: 15.0),
                  forgotLabel

                ],
              ),
            ),

          )
      )
    );
  }
}