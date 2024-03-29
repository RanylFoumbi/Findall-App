import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:findall/view/Home/Home.dart';
import 'package:toast/toast.dart';
import 'dart:convert'; //it allows us to convert our json to a list
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'DetailPage.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:page_transition/page_transition.dart';
import 'package:findall/utilities.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:findall/view/Search.dart';

class FoundList extends StatefulWidget {

  @override
  _FoundListState createState() => _FoundListState();
}

class _FoundListState extends State<FoundList> {
  LocalStorage storage = new LocalStorage('firstdata');
  List foundList = [];
  bool _isLoading = false;
  BannerAd _bannerAd;
  bool _adShown;


  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    keywords: <String>['ordinateur', 'écouteurs','electroménager','montres'],
    contentUrl: 'https://www.jumia.cm',
    childDirected: false,
    testDevices: <String>[],
  );

  BannerAd createBannerAd() {
    return new BannerAd(
//      adUnitId: "ca-app-pub-8368969673764908/5658639726",
      adUnitId: BannerAd.testAdUnitId,
      targetingInfo: targetingInfo,
      size: AdSize.banner,
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          _adShown = true;
          setState((){
          });
        } else if (event == MobileAdEvent.failedToLoad) {
          _adShown = false;
          setState((){
          });
        }
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _internetAvalability();
    FirebaseAdMob.instance.initialize(appId: 'ca-app-pub-8368969673764908~4322572982').then((res){
      _bannerAd = createBannerAd()..load()..show();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  _internetAvalability()async{
    setState(() {
      _isLoading = true;
    });
    if( await checkInternet() == true ){
      _loadData();

    }else{
      if(storage.getItem('firstdata') != null){

        setState(() {
          _isLoading = false;
          foundList = storage.getItem('firstdata');
        });
      }else{
        setState(() {
          _isLoading = false;
          foundList = null;
        });
      }
    }
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
          Toast.show("Erreur s'est produite, veuillez réessayer.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
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
      Toast.show("Veuillez vérifier votre connexion Internet, puis réessayer.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
      setState(() {
        _isLoading = false;
      });
    }

  }

  _share(image,msg,context)async{
    if( await checkInternet() == true) {
      var request = await HttpClient().getUrl(Uri.parse(image));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.file(
          'Utilisez findall pour retrouver vos objets perdus', 'foundobject.jpg', bytes,
          'image/jpg', text: msg);
    }else{
      noInternet(context,"Assurez-vous d'avoir une connexion Internet, puis réessayez.");
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
                 child: Container(
                   child: Center(
                       child: Padding(
                         padding: const EdgeInsets.only(bottom: 6.0),
                         child: Column(
                           children: <Widget>[

                             new Container(
                                 width: width,
                                 height: height/2.7,
                                 padding: const EdgeInsets.all(3.0),
                                 child:CachedNetworkImage(
                                   width: width,
                                   height: height/2.7,
                                   fit: BoxFit.cover,
                                   repeat: ImageRepeat.noRepeat,
                                   imageUrl: foundList[index]['images'][0],
                                   placeholder: (context, url) => new SpinKitWave(color: Colors.deepPurple,size: 40),
                                   errorWidget: (context, url, error) => new Icon(Icons.error,color: Colors.deepPurple),
                                 ),
                             ),

                             new Container(
                               padding: const EdgeInsets.all(7.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: <Widget>[

                                   Row(
                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: <Widget>[
                                       Expanded(
                                           child: Text(foundList[index]['objectName'], style: Theme.of(context).textTheme.title),
                                       ),


                                       new Container(
                                           decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                                               border: Border.all(color: Colors.white),
                                               color: Colors.white,
                                               boxShadow:[
                                                 BoxShadow(
                                                     color: Color(0xffd4d4d4),
                                                     blurRadius: 10.0, // has the effect of softening the shadow
                                                     offset: Offset(0,5)
                                                 )
                                               ]
                                           ),
                                           child: IconButton(
                                               color: Colors.white,
                                               iconSize: 28,
                                               icon: Icon(Icons.share,
                                                 color: Colors.deepPurple,
                                                 size: 28,
                                               ),
                                               onPressed: ()async{
                                                 _share(foundList[index]['images'][0],  ' ' + foundList[index]['objectName'] + ' ' +'retrouvé'+ ' ' +'le'+ ' ' + foundList[index]['date'] +' ' +'à'+ ' ' + foundList[index]['town'] + ','+ foundList[index]['quarter'] + '.'+ "S'il vous plaît télécharger l'application findall sur Playstore pour plus d'infos",context);
                                               }
                                           ),
                                       )

                                       
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
                                         Text('Ville:',style: TextStyle(color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic,fontSize: 11)),
                                         SizedBox(width: 3),
                                         Text(foundList[index]['town'],style: TextStyle(fontWeight: FontWeight.bold)),
                                       ]
                                   ),

                                   SizedBox(height: 5 ),

                                   Row(
                                       children: <Widget>[
                                         Icon(Icons.my_location, color: Colors.pink, size: 15),
                                         SizedBox(width: 5),
                                         Text('Quartier:',style: TextStyle(color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic,fontSize: 11)),
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
           ),
           onTap: (){
             Navigator.push(
                 context,
                 PageTransition(
                     type: PageTransitionType.leftToRight,
                     child: DetailPage(
                       index: index,
                       objectName:foundList[index]['objectName'],
                       description: foundList[index]['description'],
                       contact: foundList[index]['fouderphone'],
                       founderName: foundList[index]['founder'],
                       images: foundList[index]['images'],
                       date: foundList[index]['date'],
                       profileImg: foundList[index]['foundImage'],
                       quarter: foundList[index]['quarter'],
                       town: foundList[index]['town'],
                     )
                 )
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
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.upToDown,
                    child: Home()
                )
            );          }
      ),
      actions: <Widget>[
        foundList == null?
            IconButton(icon: Icon(Icons.search, color: Colors.white,size: 30), onPressed: null)
            :
        IconButton(
            icon: Icon(Icons.search, color: Colors.deepPurple,size: 30),
            onPressed: (){
              showSearch(
                  context: context,
                  delegate: ArticleSearch(foundList),
                  query: '',
              );
            }
        )
        ,
        SizedBox(width: 10)
      ],
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
                size: 80,
              )
          )
              :
          foundList == null
              ?
                Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 80),
                      Text("Rien n'a été retrouvé?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 30
                        )
                      ),

                      SizedBox(height: 40),

                    Center(
                      child: Image.asset('assets/images/error_loupe.png',fit: BoxFit.contain),
                    ),

                      SizedBox(height: 40),

                      Container(
                        margin: EdgeInsets.only(left: 30,right: 30),
                        child: Text("Je ne peux pas croire, je suis sûr que quelque chose a été trouvé. Veuillez vérifier votre connexion Internet, puis réessayer.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 13
                            )
                        ),
                      ),

                      SizedBox(height: 40),

                      FloatingActionButton.extended(
                        icon: Icon(Icons.settings_ethernet),
                        label: Text('Réessayer'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        backgroundColor: Colors.deepPurple,
                        heroTag: "check",
                        onPressed: (){
                          _internetAvalability();
                        },
                      ),

                      SizedBox(height: 80),

                    ],
                  ),
                )
              :
                ListView.builder(
                  itemBuilder: _buildProductItem,
                  itemCount: foundList.length,
                  scrollDirection: Axis.vertical,
                  key: Key(foundList.length.toString()),
                  padding: EdgeInsets.only(bottom: 53),
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

        },
    );
  }
}





