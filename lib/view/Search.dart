import 'package:flutter/material.dart';
import 'package:findall/view/Found/DetailPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class ArticleSearch extends SearchDelegate<ArticleSearch>{

  List articles = new List();
  int index;
  String objectName;
  String description;
  String town;
  String quarter;
  String date;
  String contact;
  List images;
  ArticleSearch(this.articles);

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => "Nom de l'objet ou la ville";

  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return ThemeData(
      primaryColor: Colors.white,
      textTheme: TextTheme(
        body1: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black,
            fontSize: 17,
            fontFamily: 'Raleway',
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return  [
      IconButton(
          icon: Icon(
              Icons.clear,
              color: Colors.deepPurple,
              size: 27
          ),
          onPressed: (){
            query = '';
          }
      ),
      SizedBox(width: 12)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.deepPurple,size: 40),
        onPressed: (){
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions

    final results = articles.where((res)=>res['objectName'].toLowerCase().contains(query.toLowerCase()) || res['town'].toLowerCase().contains(query.toLowerCase())).toList();

    return query == ''
        ?
          ListView(
            children: <Widget>[
              new  Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 80),
                    Text("Aucun resultats",
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
                      child: Text("Rien n'a été trouvé "+"'$query'",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 13
                          )
                      ),
                    ),

                    SizedBox(height: 80),

                  ],
                ),
              )
            ],
          )
        :
    results.length == 0
        ?
        ListView(
          children: <Widget>[
            new  Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 80),
                  Text("Aucun resultats",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.deepPurple,
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
                    child: Text("Rien n'a été trouvé "+"'$query'",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 13
                        )
                    ),
                  ),

                  SizedBox(height: 80),

                ],
              ),
            )
          ],
        )
        :
    new ListView(
      children: results.map<GestureDetector>((item) => new GestureDetector(
        child: new Card(
          margin: EdgeInsets.only(
              bottom: 3,
              left: 3,
              right: 3
          ),
          child: new Row(
            children: <Widget>[

              Container(
                height: 100,
                width: 130,
                child: CachedNetworkImage(
                  imageUrl:  item['images'][0],
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.noRepeat,
                  width: 130,
                  placeholder: (context, url) => new SpinKitWave(color: Colors.deepPurple,size: 35),
                  errorWidget: (context, url, error) => new Icon(Icons.error,color: Colors.deepPurple),
                )

              ),

              SizedBox(width: 15),

              new Container(
                height: 100,
                child: Column(
                  children: <Widget>[


                    Align(
                        alignment: Alignment.topLeft,
                        child:  Container(
                          margin: EdgeInsets.only(top: 30,),
                          child: Text(item['objectName'],
                            style:TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w700
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        )
                    ),

                    SizedBox(height: 5),

                    Container(
                        height: 15,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: <Widget>[
                            Icon(Icons.date_range, color: Colors.pink, size: 17,),
                            SizedBox(width: 5 ),
                            Text(item['date'], style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13), overflow: TextOverflow.ellipsis,)
                          ],
                        )
                    ),

                    SizedBox(height: 5),

                    Container(
                      height: 17,
                      margin: EdgeInsets.only(top: 0),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: <Widget>[
                          Icon(Icons.my_location, color: Colors.pink, size: 17,),
                          SizedBox(width: 5 ),
                          Text(item['town'] ,
                            overflow: TextOverflow.ellipsis, ),

                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          color: Colors.white,
          shape: Border(bottom: BorderSide(color: Color(0xffeaeff2))),
        ),
        onTap: (){
          query = item['objectName'].toLowerCase();

          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: DetailPage(
                    index: index,
                    objectName:item['objectName'],
                    description: item['description'],
                    contact: item['fouderphone'],
                    founderName:item['founder'],
                    images: item['images'],
                    date: item['date'],
                    profileImg: item['foundImage'],
                    quarter: item['quarter'],
                    town: item['town'],
                  )
              )
          );

        },
      )
      ).toList()
    );
  }



}