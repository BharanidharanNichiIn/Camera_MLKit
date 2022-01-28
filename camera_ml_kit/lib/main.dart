import 'package:camera/camera.dart';
import 'package:camera_ml_kit/ocr/ocr_scanner_view.dart';
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
    Navigator.push(context, MaterialPageRoute(builder: (context)=>OCRScannerView((text){

    })));
  }
}
