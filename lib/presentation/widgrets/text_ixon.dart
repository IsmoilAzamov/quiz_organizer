import 'package:flutter/material.dart';

Widget textIcon({required Color color}){
  //icon from assets
 return Container(
   margin: const EdgeInsets.all(5),
      width: 20,
      height: 20,
     child: Center(child: Image.asset('assets/icons/message.png',color: color,)));
}