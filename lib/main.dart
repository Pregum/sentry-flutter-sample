import 'dart:typed_data';

import 'package:error_reporter/matrix4d_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'dart:ui' as ui;

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      // TODO: ここに自分のプロジェクトのdsnを設定
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

  Matrix4 matrix = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Matrix4dWidget(),
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

  /// 画面のスクリーンショットを取得します。
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
}
