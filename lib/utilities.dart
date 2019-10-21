import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

  Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  noInternet(context,msg){

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              msg,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17
              ),
              textAlign: TextAlign.center,
            ),
            contentPadding: EdgeInsets.all(7.0),
            backgroundColor: Colors.white,
            shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Color(0xffdcdcdc)
                )
            ),
            children: <Widget>[
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.deepPurple
                      )
                  )
              ),
            ],
          );
        }
    );
  }


   photoView(context,image){
    print(image);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: PhotoView(
                imageProvider: NetworkImage(image),
                loadingChild: SpinKitWave(color: Colors.deepPurple,size: 50),
              )
          );
        }
    );
  }

