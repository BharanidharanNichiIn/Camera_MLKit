import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:touchable/touchable.dart';
import '../../../main.dart';

class CameraView extends StatefulWidget {
  final CanvasTouchDetector? canvasTouchDetector;
  final Function(InputImage inputImage) onImage;
  final CameraLensDirection initialDirection;

  const CameraView({Key? key, required this.canvasTouchDetector, required this.onImage, this.initialDirection = CameraLensDirection.back}) : super(key: key);
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver{
  CameraController? _controller;
  int _cameraIndex = 0;

  @override
  void dispose() {
    disposeController();
    WidgetsBinding.instance!.removeObserver(this);
    debugPrint("...***...dispose...***...");
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    initController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      disposeController();
      debugPrint("...***...inactive dispose...***...");
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        initController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return cameraPreview();
  }

  Widget cameraPreview() {
    if (_controller==null || _controller?.value.isInitialized == false) {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller!),
          if (widget.canvasTouchDetector != null)
            widget.canvasTouchDetector!
        ],
      ),
    );
  }

  initController() async{
    if (!mounted) {
      return;
    }
    final CameraController cameraController = CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);
    _controller = cameraController;

    try {
      await cameraController.initialize().then((value){
        cameraController.startImageStream(_processCameraImage);
      });
    } on CameraException catch (e) {
      debugPrint("...***...exception...***...");
      debugPrint(e.toString());
    }
    if (mounted) {
      setState(() {});
    }
  }

  disposeController(){
    if(_controller!=null){
      _controller?.dispose();
    }
  }

  _processCameraImage(CameraImage image) {
    WriteBuffer? allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final imageRotation = InputImageRotationMethods.fromRawValue(cameras[_cameraIndex].sensorOrientation) ?? InputImageRotation.Rotation_0deg;
    final inputImageFormat = InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21;

    final planeData = image.planes.map((Plane plane) {
      return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width);
    }).toList();

    final inputImageData = InputImageData(size: imageSize, imageRotation: imageRotation, inputImageFormat: inputImageFormat, planeData: planeData);
    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    widget.onImage(inputImage);
  }

}

