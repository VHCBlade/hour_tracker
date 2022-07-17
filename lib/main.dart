import 'package:event_navigation/event_navigation.dart';
import 'package:flutter/material.dart';
import 'package:hour_tracker/bloc_layer.dart';
import 'package:hour_tracker/repository_layer.dart';
import 'package:hour_tracker/screens/main.dart';
// import 'package:hour_tracker/theme.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const RepositoryLayer(child: BlocLayer(child: AppLayer()));
  }
}

class AppLayer extends StatelessWidget {
  const AppLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const EventNavigationApp(
      title: 'Party Crasher',
      // theme: createTheme(),
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}
