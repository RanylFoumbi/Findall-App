import 'package:flutter/material.dart';
import 'package:findall/view/Authentication/Login.dart';
import 'package:findall/view/Authentication/Signup.dart';

class NewFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[

          Container(
            child: DefaultTabController(
                          length: 2,
                          child: Scaffold(
                            appBar: AppBar(
                              backgroundColor: Colors.deepPurple,
                              iconTheme: IconThemeData(color: Colors.white),
                              bottom: TabBar(

                                tabs: <Widget> [
                                  Container(
                                      width: size.width,
                                      height: 15,
                                      alignment: Alignment.center,
                                      child: Text("Login")
                                  ),
                                  Tab(
                                    child:  Container(
                                      width: size.width,
                                      height: 15,
                                      alignment: Alignment.center,
                                      child: Text("Signup")
                                   ),
                                  )

                                ],
                              ),
                            ),
                            body: TabBarView(
                              children: [
                                Container(
                                    child: LoginPage(),
                                ),
                                Container(
                                  child: SignupPage(),
                                ),
                              ],
                            ),
                          ),
                        )

          ),


        ],
      ),
    );
  }
}

