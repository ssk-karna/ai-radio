import 'package:ai_radio/utils/ai_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';

import '../model/radio.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageStateState();
}

class _HomePageStateState extends State<HomePage> {
   List<MyRadio> radios = <MyRadio>[];

 @override
  void initState() {
    // TODO: implement initState
    fetchRadios();
    super.initState();
  }

  Future<List<MyRadio>> fetchRadios() async {
     final radioJson = await rootBundle.loadString("assets/radio.json");
     radios = MyRadioList.fromJson(radioJson).radios;
     return radios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          VxAnimatedBox()
          .size(context.screenWidth, context.screenHeight)
          .withGradient(LinearGradient(
              colors: [
                AIColors.primaryColor1,
                AIColors.primaryColor2
              ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,),
          ).make(),
          AppBar(
            title: "AI Radio".text.xl4.bold.white.make().shimmer(
              primaryColor: Vx.purple300,
              secondaryColor: Colors.white
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ).h(100.0).p16(),

          FutureBuilder(
            future: fetchRadios(),
            builder: ( context, data) {
              if(data.hasError){
                return Center(child: Text("{$data.error}"),);
              }
              else if(data.hasData){
                return VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    enlargeCenterPage: true,
                    itemBuilder: (context, index){
                      final rad =  radios[index];
                      return VxBox(
                          child: ZStack([])
                      ).bgImage(DecorationImage(
                        image: NetworkImage(rad.image),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken))
                      ).border(color: Colors.black, width: 5.0)
                      .withRounded(value: 60.0)
                          .make()
                      .p16()
                      .centered();
                    });
              }
              else{
                return Center(child: Text("Other error"));
              }
            },
          )
        ],
        fit: StackFit.expand,
      ),
    );
  }


}
