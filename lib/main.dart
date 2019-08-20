import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:longpress/bloc/bloc.dart';
import 'package:longpress/ticker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TimerBloc _timerBloc = TimerBloc(ticker: Ticker());

  double _direction;

  /*
   <stop
         stop-color="#FF8400"
         offset="0"
         id="stop10" />
      <stop
         stop-color="#F02E1C"
         offset="1"
         id="stop12" />
  */
  final Widget _svgImage = new SvgPicture.asset('images/buttonalert.svg');
  final Widget _svgImageOverlay4 =
      new SvgPicture.asset('images/buttoncompass.svg');
  final Widget _svgImageOverlay3 =
      new SvgPicture.asset('images/buttoninner3.svg');
  final Widget _svgImageOverlay2 =
      new SvgPicture.asset('images/buttoninner2.svg');
  final Widget _svgImageOverlay1 =
      new SvgPicture.asset('images/buttoninner1.svg');

  final Widget _svgImageCompassArrow =
      new SvgPicture.asset('images/compass_arrow.svg');

  void _longPressStart() {
    print("long press started");
    if (_timerBloc.currentState is Ready) {
      _timerBloc.dispatch(Start(duration: _timerBloc.currentState.duration));
    }
  }

  void _longPressUp() {
    print("long press up");
    if (_timerBloc.currentState is Running) {
      _timerBloc.dispatch(Reset());
    }
  }

  Widget _getSvgOverlayImage(int seconds) {
    if (seconds > 3) {
      return _svgImageOverlay4;
    } else if (seconds > 2) {
      return _svgImageOverlay3;
    } else if (seconds > 1) {
      return _svgImageOverlay2;
    } else if (seconds >= 0) {
      return _svgImageOverlay1;
    }
  }

  @override
  void initState() {
    super.initState();
    FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
  }

  Widget _getCompassImage(int remainingSeconds) {
    return remainingSeconds < 4
        ? SizedBox()
        : Transform.rotate(
            angle: ((_direction ?? 0) * (math.pi / 180) * -1),
            child: _svgImageCompassArrow,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: <Widget>[
            BlocProvider(
              bloc: _timerBloc,
              child: GestureDetector(
                onLongPress: _longPressStart,
                onLongPressUp: _longPressUp,
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: BlocBuilder(
                      bloc: _timerBloc,
                      builder: (context, state) {
                        final int remainingSeconds =
                            (state.duration % 60).floor();
                        return Center(
                          child: Stack(
                            children: <Widget>[
                              _svgImage, //child: Image.asset('images/greenbutton.png'),
                              _getSvgOverlayImage(remainingSeconds),
                              _getCompassImage(remainingSeconds)
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
            BlocBuilder(
              bloc: _timerBloc,
              builder: (context, state) {
                final int remainingSeconds = (state.duration % 60).floor();
                final String minutesStr = ((state.duration / 60) % 60)
                    .floor()
                    .toString()
                    .padLeft(2, '0');
                final String secondsStr =
                    (state.duration % 60).floor().toString().padLeft(2, '0');
                return remainingSeconds > 3
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Center(
                        child: Text(
                          '$minutesStr:$secondsStr',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timerBloc.dispose();
    super.dispose();
  }
}
