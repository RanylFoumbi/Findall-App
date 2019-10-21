import 'package:findall/Model/Found.dart';
import 'package:flutter/material.dart';
import 'package:findall/view/Found/FoundList.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';

import '../../utilities.dart';

class DetailPage extends StatelessWidget {

  int index;
  String objectName;
  String description;
  String town;
  String quarter;
  String date;
  String contact;
  List images;
  var profileImg;
  String founderName;

  DetailPage({Key key,
              this.index,
              this.objectName,
              this.description,
              this.town,
              this.quarter,
              this.contact,
              this.images,
              this.profileImg,
              this.founderName,
              this.date
        }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;



    final topBar =  new Row(
      children: <Widget>[
        new IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.deepPurple,size: 40),
            onPressed: (){
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: FoundList()
                  )
              );
            }
        ),

       SizedBox(width: width/2.4),
        Text('Trouvé par'+ ' ' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),

        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple,width: 0.5),
              borderRadius: BorderRadius.circular(50),
              color: Colors.white10,
          ),
          height: 50,
          width: 50,
          child: this.profileImg == null
                                      ?
                                        Icon(Icons.person,size: 45, color: Colors.deepPurple)
                                      :
                                        GestureDetector(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: Image.network(this.profileImg,fit: BoxFit.cover,height: 50,width: 50),
                                          ),
                                          onTap: (){
                                            photoView(context, this.profileImg);
                                          },
                                        )
          ,
        ),
      ],
    );


    final slider = Container(
      margin: EdgeInsets.only(left: 15,right: 15,top: 10),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffeaeff2),width: 0.5),
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0xffd4d4d4),
                blurRadius: 10.0, // has the effect of softening the shadow
                offset: Offset(0,4)
            )
          ]
        ),
      width: width,
      height: height/1.5,
      child: new Swiper(
        itemWidth: height/1.5,
        itemBuilder: (BuildContext context,int index){
          return GestureDetector(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child:CachedNetworkImage(
                    height: height/1.5,
                    imageUrl: this.images[index],
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.noRepeat,
                    placeholder: (context, url) => SpinKitFadingCircle(color: Colors.deepPurple,size: 50),
                    errorWidget: (context, url, error) => new Icon(Icons.error,color: Colors.deepPurple,size: 35)
                )
            ),
            onTap: (){
              photoView(context,this.images[index]);
            },
          );
        },
        itemCount: this.images.length,
        autoplay: true,
        pagination: new SwiperPagination(margin: EdgeInsets.all(0),),
        control: new SwiperControl(
            padding: EdgeInsets.all(0),
            color: Colors.deepPurple,
            size: 0,
            iconPrevious: null,
            iconNext: null,
          ),
      ),
    );



    final objectName = Container(
      padding: EdgeInsets.only(top: height/35,left: width/11,right: width/13,bottom: height/35),
      margin:  EdgeInsets.only(left:15.0,right: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffeaeff2)),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Center(
                    child: Text(this.objectName , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)
                    ),
              )
          )
        ],
      )
    );


    final description = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Container(child: Text('Description:' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15))),
          SizedBox(width: width/30),
          Container(
            child: Expanded(child: Text(this.description , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
          )
        ],
      );


    final location = Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Text('Location:' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: width/30),
          Expanded(child: Text(this.town + ', '+ this.quarter  , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)))
        ],
      )
    );

    final date = Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
            Text('Date de découverte:' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: width/30),
          Expanded(child: Text( this.date  , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)))
        ],
      )
    );

    final contact = Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Text('Contact:' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: width/30),
          Expanded(child: Text(this.contact, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)))
        ],
      )
    );

    final founderName = Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Text('Par:' ,  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(width: width/8),
          Expanded(child: Text(this.founderName , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)))
        ],
      )
    );


    final content = Container(
      margin:  EdgeInsets.only(left:17.0,right: 17.0),
      padding:  EdgeInsets.only(top: height/35,left: width/15,right: width/15,bottom: height/35),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffeaeff2)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          description,
          SizedBox(height: height/35),
          location,
          SizedBox(height: height/35),
          date,
          SizedBox(height: height/35),
          contact,
          SizedBox(height: height/35),
          founderName
        ],
      ),
    );

    final bottomButton = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[

        Container(
          height: 55,
          width: width/2.6,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  color: Color(0xffd4d4d3),
                  blurRadius: 10.0, // has the effect of softening the shadow
                  offset: Offset(2,7)
              )
            ]
          ),
          child: FloatingActionButton.extended(
            icon: Image.asset('assets/images/map.png',height: 25,width: 25,),
            label: Text('Map'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            backgroundColor: Colors.pink,
            heroTag: "map$index",
            onPressed: (){
              Toast.show("Bientôt disponible!", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
            },
          ),
       ),

        Container(
          height: 55,
          width: width/2.6,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Color(0xffd4d4d3),
                    blurRadius: 10.0, // has the effect of softening the shadow
                    offset: Offset(2,7)
                )
              ]
          ),
          child: FloatingActionButton.extended(
            icon: Icon(Icons.phone,size: 30,color: Colors.deepPurple,),
            label: Text('Appel',style: TextStyle(color: Colors.deepPurple),),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            backgroundColor: Colors.white,
            heroTag: "call$index",
            onPressed: (){
              UrlLauncher.launch('tel:'+ this.contact);
            },
        ),
       ),
      ],
    );


    return WillPopScope(
        child: Scaffold(
          body: ListView(
            padding: EdgeInsets.only(left: 5,top: 5,right: 5,bottom: 45),
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(height: 20),
              topBar,
              SizedBox(height: 07),
              slider,
              SizedBox(height: 30),
              objectName,
              SizedBox(height: 10),
              content,
              SizedBox(height: 20),
              bottomButton,
              SizedBox(height: 20)
            ],
          ),
        ),
        onWillPop: (){
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: FoundList()
              )
          );
        }
    );
  }



}


List getListOfFoundObjets() {
  return [
    Found(
        imageUrl: ["assets/images/saintesprit.jpg", "assets/images/ranyl.jpg", "assets/images/google.jpg"],
        objectName: "Carte Nationale d'identitée ",
        town: 'Youndé',
        quater: 'Mimboman',
        date: 'Mon 04 Jan 2019',
        founderName: 'Ranyl Foumbi',
        fouderPhone: '656801839',
        description: "Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise "
            "en page avant impression. Le Lorem Ipsum est le faux texte standard de l'imprimerie depuis"
            " les années 1500, quand un imprimeur anonyme assembla "
            "ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte. Il n'a. "),
  ];
}