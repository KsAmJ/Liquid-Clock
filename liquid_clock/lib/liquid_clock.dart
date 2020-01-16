import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'effect/liquid.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xFF81B3FE),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

class LiquidClock extends StatefulWidget {
  const LiquidClock(this.model);

  final ClockModel model;

  @override
  _LiquidClockState createState() => _LiquidClockState();
}

class _LiquidClockState extends State<LiquidClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  double _fillPercentHour;
  double _fillPercentMin;
  double _fillPercentSec;

  @override
  void initState() {
    super.initState();
    _fillPercentSec = 0;
    _fillPercentMin = 0;
    _fillPercentHour = 0;
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(LiquidClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _fillPercentSec =
          (_dateTime.second == 0 ? 0 : _dateTime.second + 1 / 60) / 60;
      _fillPercentMin =
          (_dateTime.minute == 0 ? 0 : _dateTime.minute + 1 / 60) / 60;
      _fillPercentHour =
          (_dateTime.hour == 0 ? 0 : _dateTime.hour + 1 / 24) / 24;
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double factor = MediaQuery.of(context).size.width / 380;
    if (factor < 1) factor = 1;
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = DateFormat('ss').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / (3.5 + factor);
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontSize: fontSize - 5,
      fontFamily: 'Fruktur',
      shadows: [
        Shadow(
          blurRadius: 0,
          color: colors[_Element.shadow],
          offset: Offset(10, 0),
        ),
      ],
    );

    return Container(
      height: MediaQuery.of(context).size.height - 10,
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: LiquidEffect(
                      value: _fillPercentHour == 0 ? 0 : _fillPercentHour,
                      valueColor: AlwaysStoppedAnimation(Colors.red),
                      backgroundColor: Colors.red[100],
                      direction: Axis.vertical,
                      center: Container(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: LiquidEffect(
                      value: _fillPercentMin == 0 ? 0 : _fillPercentMin,
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                      backgroundColor: Colors.green[100],
                      direction: Axis.vertical,
                      center: Container(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: LiquidEffect(
                      value: _fillPercentSec,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      backgroundColor: Colors.blue[100],
                      direction: Axis.vertical,
                      center: Container(),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(hour),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(minute),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(seconds),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
