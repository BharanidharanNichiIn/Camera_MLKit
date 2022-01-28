import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:touchable/touchable.dart';

import 'coordinates_translator.dart';

class TextDetectorPainter extends CustomPainter {
  final TextRecognitionOptions? textRecognitionOptions=null;
  final RecognisedText recognisedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final BuildContext context;
  final Function onTapOCR;

  TextDetectorPainter(this.recognisedText, this.absoluteImageSize, this.rotation,this.context,this.onTapOCR);
  @override
  void paint(Canvas canvas, Size size) {
    TouchyCanvas _canvas = TouchyCanvas(context,canvas);

    for(int i=0;i<recognisedText.blocks.length;i++){
      final textBlock=recognisedText.blocks[i];
      final ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.left, fontSize: 14, textDirection: TextDirection.ltr));
      builder.pushStyle(ui.TextStyle(color: Colors.white,));
      builder.addText(textBlock.text);
      builder.pop();

      final left = translateX(textBlock.rect.left, rotation, size, absoluteImageSize);
      final top = translateY(textBlock.rect.top, rotation, size, absoluteImageSize);
      final right = translateX(textBlock.rect.right, rotation, size, absoluteImageSize);
      final bottom = translateY(textBlock.rect.bottom, rotation, size, absoluteImageSize);

      _canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = Colors.white,
          onTapDown: (_)=> setSelectedDetails(textBlock));
      _canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), Paint()..style = PaintingStyle.fill..color = Colors.transparent,
          onTapDown: (_)=> setSelectedDetails(textBlock));
      _canvas.drawParagraph(builder.build()..layout(ParagraphConstraints(width: right - left,)), Offset(left, top));
    }
  }

  setSelectedDetails(textBlock){
    onTapOCR(textBlock.text.toString().replaceAll("\n", " "));
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.recognisedText != recognisedText;
  }

}
