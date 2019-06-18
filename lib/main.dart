import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:longpress/bloc/bloc.dart';
import 'package:longpress/ticker.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final Widget _svgImage = new SvgPicture.asset('images/buttongreen.svg');

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
            BlocProvider(
              bloc: _timerBloc,
              child: GestureDetector(
                onLongPress: _longPressStart,
                onLongPressUp: _longPressUp,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child:
                      _svgImage, //child: Image.asset('images/greenbutton.png'),
                ),
              ),
            ),
            BlocBuilder(
              bloc: _timerBloc,
              builder: (context, state) {
                final String minutesStr = ((state.duration / 60) % 60)
                    .floor()
                    .toString()
                    .padLeft(2, '0');
                final String secondsStr =
                    (state.duration % 60).floor().toString().padLeft(2, '0');
                return Text(
                  '$minutesStr:$secondsStr',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent),
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
