import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(child: Center(child: Column(
      children: [
        ElevatedButton(onPressed: (){
          context.go("/biz");
        }, child: Text("g")),
        Text("test"),
      ],
    ),),),);
  }
}
