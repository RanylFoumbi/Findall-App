import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:findall/view/Found/CreateNewFoundPage.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:findall/view/Home/Home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class SMSLoginPage extends StatefulWidget {
  @override
  _SMSLoginPageState createState() => _SMSLoginPageState();
}

class _SMSLoginPageState extends State<SMSLoginPage> {

  LocalStorage storage = new LocalStorage('userphoneNumber');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final numController = TextEditingController();

  String smsCode;
  String verificationId;
  bool _loading;

  @override
  void initState() {
    numController.text = "+237";
    _loading = false;
    super.initState();
  }

  Future<void> verifyPhone() async {
    setState(() {
      _loading = true;
    });
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      print("Sign in");
      smsCodeDialog(context).then((value) {
      }).catchError((err) {
        Toast.show("Code Erroné.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      });
    };

    final verificationCompleted = (user) {
      print("Verified");
    } ;

    final PhoneVerificationFailed verifiedFailed = (AuthException exception) {
      print("${exception.message}");
    };
    try {
      setState(() {
        _loading = true;
      });
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: numController.text,
          codeAutoRetrievalTimeout: autoRetrieve,
          codeSent: smsCodeSent,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verifiedFailed
      );

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print("Error");
      Toast.show("Erreur, Veuillez reésayer.", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
    }
    setState(() {
      _loading = false;
    });
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Entrez le code sms"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: Color(0xffdcdcdc))),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              RaisedButton(
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    signIn().then((user) {
                      storage.setItem('userphoneNumber', numController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateNewFound(),
                        ),
                      );
                      print(user);
                    }).catchError((err) {
                      Toast.show("Code Invalide", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                      Navigator.of(context).pop();
                      print(err);
                    });
                  });
                 },
                color: Colors.pink,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Text("Valider",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontSize: 14.0,
                      ),
                  ),
              )

            ],
          );
        }
    );
  }

  Future<FirebaseUser> signIn() async {

    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: this.verificationId,
      smsCode: this.smsCode,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential).then((user){
      setState(() {
        user = user;
      });
    });
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 100.0, right: 25.0, left: 25.0, bottom: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset("assets/images/logo_findall.png", height: 110, width: 110),
                    ),
                    const SizedBox(height: 20.0),
                    Row(children: <Widget>[
                      CountryCodePicker(
                        onChanged: (val) { numController.text = val.toString();},
                        initialSelection: 'CM',
                        favorite: ['+237','FR'],
                        showCountryOnly: false,
                        alignLeft: false,
                      ),
                    ],mainAxisAlignment: MainAxisAlignment.center,),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: numController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Phone Number",
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color(0xffdcdcdc)),
                            borderRadius: BorderRadius.circular(10.0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Color(0xfff4f4f4),
                        ),
                      ),
                      validator: (String value) {
                        if(value.length <= 4) {
                          return "Entrez un numéro de téléphone";
                        }
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        alignment: _loading ? Alignment.center : null,
                        height: 50,
                        child: !_loading ? RaisedButton(
                          onPressed: () {
                            _formKey.currentState.validate();
                            setState(() {
                              _loading = true;
                            });
                            verifyPhone().then((val) {
                              setState(() {
                                _loading = false;
                              });
                            })
                                .catchError((err) {
                              print(err);
                              Toast.show("Numéro invalide", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                            });

                          },
                          color: Colors.pink,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Text(
                            "CONTINUER",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 16.0,
                            ),
                          ),
                        ) : SpinKitWave(color: Colors.deepPurple,size: 30)
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      alignment: Alignment.center,
                      child: Text("Entrez votre numéro de téléphone. Vous recevrez un code de confirmation par sms.",
                        style: TextStyle(fontSize: 14.0), textAlign: TextAlign.center, ) ,
                    )
                  ],
                ),
              )),
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
