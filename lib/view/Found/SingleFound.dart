/*
import 'package:flutter/material.dart';
import 'package:findall/Model/Found.dart';


class singleCard extends StatelessWidget {

  const singleCard(
      {Key key, this.singleFound, this.onTap, @required this.item, this.selected: false}
      ) : super(key: key);

  final Found singleFound;
  final VoidCallback onTap;
  final Found item;
  final bool selected;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected)
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    return Card(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            new Container(
                padding: const EdgeInsets.all(2.0),
                child:Image.asset(
                    singleFound.imageUrl[0],
                    fit: BoxFit.cover,
                    width: width,
                    height: height/3,
                )),
            new Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      Text(singleFound.objectName, style: Theme.of(context).textTheme.title),
                    Container(
                        margin: EdgeInsets.only(top: 15),
                        height: 20,
                        width: width,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: <Widget>[
                            Icon(Icons.date_range, color: Colors.pink, size: 15,),
                            SizedBox(width: 5 ),
                            Text(singleFound.date, style: TextStyle(color: Colors.black.withOpacity(0.5),fontSize: 13), overflow: TextOverflow.ellipsis,)
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
                          Text(singleFound.town,style: TextStyle(fontWeight: FontWeight.bold)),
                        ]
                    ),

                    SizedBox(height: 5 ),

                    Row(
                        children: <Widget>[
                          Icon(Icons.my_location, color: Colors.pink, size: 15),
                          SizedBox(width: 5),
                          Text('Quater:',style: TextStyle(color: Colors.black.withOpacity(0.6),fontStyle: FontStyle.italic,fontSize: 11)),
                          SizedBox(width: 3),
                          Text(singleFound.quarter,style: TextStyle(fontWeight: FontWeight.bold)),
                        ]
                    ),
                  ],
              ),

            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        )
    );
  }
}*/
