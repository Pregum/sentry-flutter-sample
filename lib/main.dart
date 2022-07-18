import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'dart:ui' as ui;

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@xxxxxxxx.ingest.sentry.io/xxxxxxx';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(
      const MyApp(),
    ),
  );
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey globalKey = GlobalKey();

  double rotateX = 1.0;
  double rotateY = 1.0;
  double rotateZ = 1.0;
  double offsetX = 0;
  double offsetY = 0;

  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    const size = Size(50, 50);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform(
              origin: Offset(offsetX, offsetY),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.003)
                ..setEntry(3, 1, 0.001)
                ..rotateX(rotateX.toRadian())
                ..rotateY(rotateY.toRadian())
                ..rotateZ(rotateZ.toRadian()),
              child: Center(
                child: Container(
                  height: size.height,
                  width: size.width,
                  color: Colors.blue,
                ),
              ),
            ),
            _buildSlider(
              onChange: (newValue) => setState(() {
                rotateX = newValue;
              }),
              val: rotateX,
            ),
            _buildSlider(
              onChange: (newValue) => setState(() {
                rotateY = newValue;
              }),
              val: rotateY,
            ),
            _buildSlider(
              onChange: (newValue) => setState(() {
                rotateZ = newValue;
              }),
              val: rotateZ,
            ),
            _buildSlider(
              onChange: (newValue) => setState(() => offsetX = newValue),
              val: offsetX,
              min: -MediaQuery.of(context).size.width,
              max: MediaQuery.of(context).size.width,
            ),
            _buildSlider(
              onChange: (newValue) => setState(() => offsetY = newValue),
              val: offsetY,
              min: -MediaQuery.of(context).size.height,
              max: MediaQuery.of(context).size.height,
            ),
            ElevatedButton(
              onPressed: () {
                _handleOnTapFailButton();
              },
              child: const Text('send error report!'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOnTapFailButton() async {
    try {
      throw Exception('intendedly occurs error');
    } catch (exception, stackTrace) {
      final bytes = await _screenCapture();

      final attachment =
          SentryAttachment.fromUint8List(bytes, 'screenshot_samp.png');
      await Sentry.captureException(exception, stackTrace: stackTrace,
          withScope: (scope) async {
        scope.addAttachment(attachment);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('send report!'),
          duration: Duration(
            milliseconds: 1500,
          ),
        ),
      );
    }
  }

  Future<Uint8List> _capturePng() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  Future<Uint8List> _screenCapture() async {
    final builder = ui.SceneBuilder();
    final scene =
        RendererBinding.instance.renderView.layer?.buildScene(builder);
    final image = await scene?.toImage(ui.window.physicalSize.width.toInt(),
        ui.window.physicalSize.height.toInt());
    scene?.dispose();
    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  /// sliderを生成
  Widget _buildSlider(
      {void Function(double newValue)? onChange,
      required double val,
      double? max,
      double? min}) {
    return Slider(
      label: "test: ${val.toStringAsFixed(0)}",
      divisions: 360,
      max: max ?? 360.0,
      min: min ?? 0.0,
      onChanged: (double value) {
        onChange?.call(value);
      },
      value: val,
    );
  }
}

extension DoubleExtension on double {
  double toRadian() {
    return this * (pi / 180);
  }
}
