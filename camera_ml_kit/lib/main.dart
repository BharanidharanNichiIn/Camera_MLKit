import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Home"),),body: Column(children: [
      Center(child: TextButton(onPressed: (){
        navigateToCameraView();
      }, child: const Text("Open Camera")),)
    ],mainAxisAlignment: MainAxisAlignment.center,));
  }

  navigateToCameraView(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>const CameraView()));
  }
}

class CameraView extends StatefulWidget {
  final CameraLensDirection initialDirection;

  const CameraView({Key? key, this.initialDirection = CameraLensDirection.back}) : super(key: key);
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
      child: CameraPreview(_controller!),
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
        cameraController.startImageStream((cameraImage){});
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

}

