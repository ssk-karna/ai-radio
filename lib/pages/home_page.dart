import 'package:ai_radio/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:alan_voice/alan_voice.dart';
import '../model/radio.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageStateState();
}

class _HomePageStateState extends State<HomePage> {
   List<MyRadio> radios = <MyRadio>[];
   late MyRadio _selectedRadio;
    Color _selectedColor = Color(int.parse("0xffB2DFDB"));
   bool _isPlaying = false;

   final AudioPlayer _audioPlayer = AudioPlayer();

 @override
  void initState() {
    // TODO: implement initState
   setupAlan();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if(event == PlayerState.playing){
        _isPlaying = true;
      }
      else{
        _isPlaying = false;
      }
      setState(() { });
    });

    super.initState();
  }

  Future<List<MyRadio>> fetchRadios() async {
     final radioJson = await rootBundle.loadString("assets/radio.json");
     radios = MyRadioList.fromJson(radioJson).radios;
     _selectedRadio = radios[0];
     _selectedColor = Color(int.parse(_selectedRadio.color));
     setState(() {});
     return radios;
  }

   setupAlan(){
     AlanVoice.addButton(
         "206fc84679f841f09ced24f73343181c2e956eca572e1d8b807a3e2338fdd0dc/stage",
       buttonAlign:AlanVoice.BUTTON_ALIGN_LEFT);
     AlanVoice.callbacks.add((command) => _handleCommand(command.data));
}
   _handleCommand(Map<String,dynamic> response){
   switch (response["command"]){
     case "play":
       _playMusic(_selectedRadio.url);
       break;
     default:
       print("Command was ${response["command"]}");
       break;
   }
   }
  _playMusic(String url){
   _audioPlayer.play(UrlSource(url));
   _selectedRadio = radios.firstWhere((element) => element.url == url);
   print(_selectedRadio.name);
   setState(() { });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
        children: [
          VxAnimatedBox()
          .size(context.screenWidth, context.screenHeight)
          .withGradient(LinearGradient(
              colors: [
                AIColors.primaryColor2,
               _selectedColor ?? AIColors.primaryColor1,
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
                      onPageChanged: (index){
                        final colorHex =  radios[index].color;
                        _selectedColor = Color(int.parse(colorHex));
                        setState(() { });
                      },
                      itemBuilder: (context, index){
                        final rad =  radios[index];
                        return VxBox(
                            child: ZStack([
                             Positioned(
                               top: 0.0,
                             right: 0.0,
                                 child: VxBox(
                                   child: rad.category.text.uppercase.white.make().p16(),
                                 ).height(52)
                                 .black
                                 .alignCenter
                                 .withRounded(value: 10.0)
                                 .make() as Widget
                             ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: VStack(
                                  [
                                    rad.name.text.xl3.white.bold.make(),
                                    5.heightBox,
                                    rad.tagline.text.sm.white.semiBold.make()
                                  ],
                                  crossAlignment: CrossAxisAlignment.center,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: [
                                  Icon(CupertinoIcons.play_circle,
                                      color: Colors.white ),
                                  10.heightBox,
                                  "Double tap to play".text.gray300.make(),
                              ].vStack()
                              )
                            ])
                        ).clip(Clip.antiAlias)
                            .bgImage(DecorationImage(
                          image: NetworkImage(rad.image),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken))
                        ).border(color: Colors.black, width: 5.0)
                        .withRounded(value: 60.0)
                            .make()
                        .onInkDoubleTap(() {
                          _playMusic(rad.url);
                        })
                        .p16();
                      }).centered();
              }
              else{
                return Center(child: Text("Other error"));
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if(_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM".text.makeCentered(),
              Icon(_isPlaying ? CupertinoIcons.stop_circle
                :CupertinoIcons.play_circle,
              color: Colors.white,
                size: 50.0).onInkTap(() {
                  if(_isPlaying){
                    _audioPlayer.stop();
                  }
                  else{
                    _playMusic(_selectedRadio.url);
                  }
              }),
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
      ),
    );
  }


}
