import 'package:flutter/material.dart';
import 'package:findall/view/Home/Home.dart';
import 'package:toast/toast.dart';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'DetailPage.dart';

class FoundList extends StatefulWidget {

  @override
  _FoundListState createState() => _FoundListState();
}

class _FoundListState extends State<FoundList> {
  LocalStorage storage = new LocalStorage('firstdata');
  List foundList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }




  _loadData() async{

    var url ='https://testfinder-5bdda.firebaseio.com/foundedObject.json';

    try {

      setState(() {
        _isLoading = true;
      });

      var response = await http.Client().get(url);
      Map decodeResponse = jsonDecode(response.body);

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {

        setState(() {
          foundList = decodeResponse.values.toList();
        });

        storage.setItem('firstdata',decodeResponse.values.toList());

      }
      else {
        setState(() {
          _isLoading = true;
        });
        setState(() {
          foundList = storage.getItem('firstdata');
        });
          // Une autre Erreur

          print("Une érreur s'est produite, veuillez reéssayer.");
          Toast.show("Une érreur s'est produite, veuillez reéssayer.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
          setState(() {
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _isLoading = true;
      });
      setState(() {
        foundList = storage.getItem('firstdata');
      });
      print("Pas d'internet.");
      Toast.show("veuillez vérifier votre connexion internet.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      setState(() {
        _isLoading = false;
      });
    }

  }


  Widget _buildProductItem(BuildContext context, int index){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
       return Container(
         key: Key(index.toString()),
         child: GestureDetector(
           child: Card(
             color: Colors.white,
             child: FabCircularMenu(
                 child: Container(
                   child: Center(
                       child: Padding(
                         padding: const EdgeInsets.only(bottom: 6.0),
                         child: Column(
                           children: <Widget>[

                             new Container(
                                 width: width,
                                 height: height/1.5,
                                 padding: const EdgeInsets.all(3.0),
                                 child:
                                 CachedNetworkImage(
                                   width: width,
                                   height: height/1.3,
                                   fit: BoxFit.cover,
                                   repeat: ImageRepeat.noRepeat,
                                   imageUrl: foundList[index]['images'][0],
                                   placeholder: (context, url) => new SpinKitWave(color: Colors.deepPurple,size: 40),
                                   errorWidget: (context, url, error) => new Icon(Icons.error),
                                 ),
                             ),

                             new Container(
                               padding: const EdgeInsets.all(10.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[

                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: <Widget>[
                                       Text(foundList[index]['objectName'], style: Theme.of(context).textTheme.title),

                                     ],
                                   ),
                                   SizedBox(height: 8 ),
                                   Container(
                                       height: 20,
                                       width: width,
                                       child: Wrap(
                                         crossAxisAlignment: WrapCrossAlignment.start,
                                         children: <Widget>[
                                           Icon(Icons.date_range, color: Colors.pink, size: 15,),
                                           SizedBox(width: 5 ),
                                           Text(foundList[index]['date'], style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13), overflow: TextOverflow.ellipsis,)
                                         ],
                                       )
                                   ),

                                   SizedBox(height: 5 ),
                                   Row(
                                       children: <Widget>[
                                         Icon(Icons.location_city, color: Colors.pink, size: 15),
                                         SizedBox(width: 5),
                                         Text('City:',style: TextStyle(color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic,fontSize: 11)),
                                         SizedBox(width: 3),
                                         Text(foundList[index]['town'],style: TextStyle(fontWeight: FontWeight.bold)),
                                       ]
                                   ),

                                   SizedBox(height: 5 ),

                                   Row(
                                       children: <Widget>[
                                         Icon(Icons.my_location, color: Colors.pink, size: 15),
                                         SizedBox(width: 5),
                                         Text('Quarter:',style: TextStyle(color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic,fontSize: 11)),
                                         SizedBox(width: 3),
                                         Text(foundList[index]['quarter'],style: TextStyle(fontWeight: FontWeight.bold)),
                                       ]
                                   ),

                                 ],
                               ),

                             )
                           ],
                           crossAxisAlignment: CrossAxisAlignment.start,
                         ),
                       )
                   ),
                 ),
                 ringColor: Colors.white12,
                 ringDiameter: width/1.5,
                 fabColor: Colors.white,
                 fabMargin: EdgeInsets.only(left: 24,bottom: 24,top: 10,right: 8.0),
                 fabOpenIcon: Icon(Icons.share,color: Colors.deepPurple,),
                 fabCloseIcon: Icon(Icons.close,color: Colors.deepPurple),
                 options:
                 <Widget>[
                   IconButton(icon: Icon(FontAwesomeIcons.whatsapp,color: Colors.green), onPressed: () {
                     FlutterShareMe().shareToWhatsApp(msg: 'A'+ ' ' + foundList[index]['objectName'] + ' ' +'has been found'+ ' ' +'in'+ ' ' + foundList[index]['town'] + ','+ foundList[index]['quarter'] + '.'+ 'Please download findall App on playstore for more infos');
                   }, iconSize: 28.0, color: Colors.white,key: Key(index.toString() + 'what')),

                   IconButton(icon: Icon(FontAwesomeIcons.facebook,color: Colors.black), onPressed: ()async {

                   }, iconSize: 28.0, color: Colors.white,key: Key(index.toString() + 'face')),

                   IconButton(icon: Icon(FontAwesomeIcons.twitter,color: Colors.blue,key: Key(index.toString() + 'twitter')), onPressed: () {

                   }, iconSize: 28.0, color: Colors.white),

                 ]
             ),

           ),
           onTap: (){
             Navigator.push(
                 context,
               MaterialPageRoute(
                   builder: (BuildContext context) {
                     return DetailPage(
                         index: index,
                         objectName:foundList[index]['objectName'],
                         description: foundList[index]['description'],
                         contact: foundList[index]['fouderphone'],
                         founderName: foundList[index]['founder'],
                         images: foundList[index]['images'],
                         date: foundList[index]['date'],
                         profileImg: foundList[index]['foundImage'],
                         quater: foundList[index]['quarter'],
                         town: foundList[index]['town'],
                     );
                   }),
             );
           },
         )
      );

  }



  @override
  Widget build(BuildContext context) {

    final topAppBar = new AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 1.0,
      leading: new IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.deepPurple,size: 40),
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
          }
      ),
      title: SizedBox(
        height: 40.0 ,
        child: Image.asset('assets/images/icon_findall.png', 
            width: 10,
            height: 15
        ),
        width: 60,
      ),
    );


    return WillPopScope(
        child: Scaffold(
          appBar: topAppBar,
          body:  _isLoading
              ?
          Center(
              child: SpinKitFadingCircle(color: Colors.deepPurple,
                size: 50,
              )
          )
              :
          foundList==null
              ?
                Center(
                  child: Text('Sorry there is not publish object'),
                )
              :
                PageView.builder(
                  itemBuilder: _buildProductItem,
                  itemCount: foundList.length,
                  scrollDirection: Axis.vertical,
                  key: Key(foundList.length.toString()),
                ),
        ),
        onWillPop: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Home()
              )
          );
        },
    );
  }
}

