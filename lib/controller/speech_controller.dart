
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';



class AiController extends State{
  String text='';
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> initSpeechState() async {
    var hasSpeech = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
    );
    return hasSpeech;
  }

  void startListening() {
    speech.listen(
      localeId: "English",
      onResult: (val) => setState(() {
        text = val.recognizedWords;
        print(text);
      }),
    );

  }
  void stopListening(){
    speech.stop();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}