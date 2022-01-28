import 'package:camera_ml_kit/ocr/camera_view.dart';
import 'package:camera_ml_kit/ocr/text_detector_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:touchable/touchable.dart';

class OCRScannerView extends StatefulWidget {
  const OCRScannerView(this.onTap, {Key? key}) : super(key: key);

  final Function onTap;

  @override
  OCRScannerViewState createState() => OCRScannerViewState();
}

class OCRScannerViewState extends State<OCRScannerView> {
  CanvasTouchDetector? canvasTouchDetector;
  TextDetector textDetector = GoogleMlKit.vision.textDetector();
  bool isBusy = false;

  @override
  void dispose() async {
    super.dispose();
    await textDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(canvasTouchDetector: canvasTouchDetector, onImage: (inputImage) => processImage(inputImage));
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final recognisedText = await textDetector.processImage(inputImage);
    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      canvasTouchDetector = CanvasTouchDetector(builder: (context)=>CustomPaint(painter: TextDetectorPainter(recognisedText, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation,context,(text){
        widget.onTap(text);
      },)));
    } else {
      canvasTouchDetector = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}


