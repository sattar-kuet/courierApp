import 'package:flutter/material.dart';
import 'package:flutter_app/fragments/new_pickup_point.dart';
import 'package:flutter_app/widget/loading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../common/menu_drawer.dart';
import '../common/bottom_navigation.dart';
import '../common/floating_button.dart';

class Home extends StatelessWidget {
  static const String routeName = '/homePage';
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      drawer: MenuDrawer(),
      body: Column(
        children: [
          Center(child: Text("This is Home")),
          ElevatedButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>NewPickupPoint()));
          }, child: Text("HELLO"))
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
      floatingActionButton: floating,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
