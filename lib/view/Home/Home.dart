import 'package:flutter/material.dart';
import 'package:findall/view/Authentication/SmsAuthPage.dart';
import 'package:findall/view/Found/FoundList.dart';
import 'package:localstorage/localstorage.dart';
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
                     MaterialPageRoute(builder: (context) => SMSLoginPage()),
                   )
                  :
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => SMSLoginPage()),
                   );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
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
                  onPressed: (){},
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

          DropdownButton(items: null, onChanged: null,),
          Container(
              margin: EdgeInsets.only(
                  top: size.height/1.5,
                  left: size.width/5.0
              ),
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  FloatingActionButton.extended(
                    icon: Icon(Icons.view_list),
                    label: Text('See lost objects'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    backgroundColor: Colors.pink,
                    heroTag: "pub list button",
                    onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoundList()),
                     );
                    },
                  ),
                  SizedBox(height: 25),
                  FloatingActionButton.extended(
                    icon: Icon(Icons.add),
                    label: Text('Add lost object'),
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

    );
  }
}

