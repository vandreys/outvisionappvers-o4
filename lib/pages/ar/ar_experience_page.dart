import 'package:flutter/material.dart';
import 'package:outvisionxr/models/artwork_point.dart';
class ARExperiencePage extends StatelessWidget{
final ArtworkPoint artwork; const ARExperiencePage({super.key,required this.artwork});
@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('AR View')),body:Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(artwork.title),const SizedBox(height:12),ElevatedButton(onPressed:()=>Navigator.pop(c),child:const Text('Voltar'))])));
}