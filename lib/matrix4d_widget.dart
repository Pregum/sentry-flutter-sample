import 'dart:math';

import 'package:flutter/material.dart';

class Matrix4dWidget extends StatefulWidget {
  const Matrix4dWidget({Key? key}) : super(key: key);

  @override
  State<Matrix4dWidget> createState() => _Matrix4dWidgetState();
}

class _Matrix4dWidgetState extends State<Matrix4dWidget> {
  double rotateX = 1.0;
  double rotateY = 1.0;
  double rotateZ = 1.0;
  double offsetX = 0;
  double offsetY = 0;

  @override
  Widget build(BuildContext context) {
    const size = Size(50, 50);
    return Column(
      children: [
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
          labelName: 'rotate x',
        ),
        _buildSlider(
          onChange: (newValue) => setState(() {
            rotateY = newValue;
          }),
          val: rotateY,
          labelName: 'rotate y',
        ),
        _buildSlider(
          onChange: (newValue) => setState(() {
            rotateZ = newValue;
          }),
          val: rotateZ,
          labelName: 'rotate z',
        ),
        _buildSlider(
          onChange: (newValue) => setState(() => offsetX = newValue),
          val: offsetX,
          min: -MediaQuery.of(context).size.width,
          max: MediaQuery.of(context).size.width,
          labelName: 'offset x',
        ),
        _buildSlider(
          onChange: (newValue) => setState(() => offsetY = newValue),
          val: offsetY,
          min: -MediaQuery.of(context).size.height,
          max: MediaQuery.of(context).size.height,
          labelName: 'offset y',
        ),
      ],
    );
  }

  /// sliderを生成
  Widget _buildSlider({
    void Function(double newValue)? onChange,
    required double val,
    double? max,
    double? min,
    String labelName = 'no label',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(labelName),
          Expanded(
            child: Slider(
              label: "$labelName: ${val.toStringAsFixed(0)}",
              divisions: 360,
              max: max ?? 360.0,
              min: min ?? 0.0,
              onChanged: (double value) {
                onChange?.call(value);
              },
              value: val,
            ),
          ),
        ],
      ),
    );
  }
}

extension DoubleExtension on double {
  double toRadian() {
    return this * (pi / 180);
  }
}
