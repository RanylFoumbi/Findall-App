import 'package:flutter/material.dart';
import 'dart:io';
import 'package:findall/view/Authentication/SmsAuthPage.dart';
import 'package:findall/view/Found/FoundList.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:findall/view/Found/CreateNewFoundPage.dart';


class Home extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: BackgroundImage(),
    );
  }
}



class BackgroundImage extends StatelessWidget {

  LocalStorage storage = LocalStorage('userphoneNumber');


  _verifyUser(context){
   var userphone  = storage.getItem('userphoneNumber');

   userphone == null
                   ?
                   Navigator.push(
                       context,
                       PageTransition(
                           type: PageTransitionType.fade,
                           child: SMSLoginPage()
                       )
                   )
                  :
                   Navigator.push(
                       context,
                       PageTransition(
                           type: PageTransitionType.fade,
                           child: CreateNewFound()
                       )
                   );
  }

  _about(BuildContext context){

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  AboutDialog(
            applicationIcon: Image.asset("assets/images/icon_cir.png", height: 100, width: 100),
            children: <Widget>[
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Text('   '+"Cette application vous aide à retrouver vos objets perdus tels que votre téléphone, votre carte d'identité nationale, vos certificats, votre passeport et bien d'autres choses.""De plus, vous pouvez via l'application directement localiser et appeler la personne qui a trouvé votre objet.",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                        ),
                      )
                  )
                ],
              )
            ],
            applicationVersion: '1.0',
            applicationName: 'findall',
            applicationLegalese: 'approuvé par Google play',
          );
    });
  }


  _close(BuildContext context){
     return showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
         return AlertDialog(
           shape: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffd4d4d4)),borderRadius: BorderRadius.circular(10)),
           title: Text("Voulez-vous vraiment quitter findall?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400),),
           contentPadding: EdgeInsets.all(10.0),
           backgroundColor: Colors.white,
           actions: <Widget>[
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 FlatButton(
                     onPressed: (){
                       Navigator.pop(context);
                     },
                     child: Text('NON',style: TextStyle(color: Colors.deepPurple))
                 ),

                 FlatButton(
                     onPressed: (){
                       exit(0);
                     },
                     child: Text('OUI',style: TextStyle(color: Colors.deepPurple))
                 )
               ],
             )
           ],
         );
     }
     );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      child: Container(
        child: Stack(
          children: <Widget>[

            Container(
                margin: EdgeInsets.only(),
                child: RotatedBox(
                  quarterTurns: 0,
                  child: new Image.asset(
                    'assets/images/bar_loupe.png',
                    height: size.height/0.95,
                    width: size.width/1,
                    fit: BoxFit.fill,
                  ),
                )
            ),

            Container(
              margin: EdgeInsets.only(left: size.width/1.3,top: 50),
              child: FloatingActionButton.extended(
                label: Text('?',style: TextStyle(color: Colors.pink,fontSize: 35),textAlign: TextAlign.center,),
                backgroundColor: Colors.white,
                heroTag: "question",
                onPressed: (){
                  _about(context);
                },
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: size.height/2.9,left: size.width/3.8),
              child: new Image.asset(
                'assets/images/logo_findall.png',
                height: size.height/6.5,
                fit: BoxFit.fill,
              ),
            ),


            Container(
              margin: EdgeInsets.only(top: size.height/4.2, left: size.width/5.9),
              child: new Image.asset(
                'assets/images/verre.png',
                height: size.height/2.7,
                width: size.width/1.5,
                fit: BoxFit.fill,
              ),
            ),


            Container(
              margin: EdgeInsets.only(
                left: size.width/2.55,
                top: size.height/1.05,
              ),
              child: new Text('CopyRight@ranolf2019',
                  style: new TextStyle(
                      fontSize: 8.0,
                      color: Colors.black
                  )
              ),
            ),

            Container(
              margin: EdgeInsets.only(
                  top: size.height/1.5,
                  left: size.width/6.0
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  FloatingActionButton.extended(
                    icon: Icon(Icons.view_list),
                    label: Text('Voir objets perdus'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    backgroundColor: Colors.pink,
                    heroTag: "See lost objects button",
                    onPressed: (){
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: FoundList()
                          )
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  FloatingActionButton.extended(
                    icon: Icon(Icons.add),
                      label: Text('Ajouter objet trouvé'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    backgroundColor: Colors.deepPurple,
                    heroTag: "new found button",
                    onPressed: (){
                      _verifyUser(context);
                    },
                  ),
                ],
              ),
            )

          ],
        ),

      ),
      onWillPop: (){
        _close(context);
      },
    );
  }
}

