import 'package:flutter/material.dart';

const num DESIGN_WIDTH = 375;
const num DESIGN_HEIGHT = 812;
const num DESIGN_STATUS_BAR = 0;

extension ResponsiveExtension on num {
double get _width => SizeUtils.width;
double get h => ((this * _width) / DESIGN_WIDTH).toDouble();
double get fSize => ((this * _width) / DESIGN_WIDTH).toDouble();
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(this.toStringAsFixed(fractionDigits));
  }
  double isNonZero({num defaultValue = 0}) {
    return this >0 ? this : defaultValue.toDouble();
  }
}

enum DeviceType {
  Mobile,
  Tablet,
  Desktop,
}

typedef ResponsiveBuilder = Widget Function(
  BuildContext context,
  Orientation orientation,
  DeviceType deviceType,
);

class Sizer extends StatelessWidget {
  const Sizer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final ResponsiveBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            SizeUtils.setScreenSize(
              constraints,
              orientation,
            );
            return builder(
              context,
              orientation,
              SizeUtils.deviceType,
            );
          },
        );
      },
    );
  }
}

class SizeUtils {
  static late BoxConstraints boxConstraints;
  static late Orientation orientation;
  static late DeviceType deviceType;
  static late double width;
  static late double height;

  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    if (orientation == Orientation.portrait) {
      width = boxConstraints.maxWidth.isNonZero(defaultValue: DESIGN_WIDTH);
      height = boxConstraints.maxHeight.isNonZero();
    }else{
      width = boxConstraints.maxHeight.isNonZero(defaultValue: DESIGN_WIDTH);
      height = boxConstraints.maxWidth.isNonZero();
    }
    deviceType = DeviceType.Mobile;
  }

}