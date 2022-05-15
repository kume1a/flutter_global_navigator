import 'package:flutter/material.dart';
import 'package:global_navigator/global_navigator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  GlobalNavigator.navigatorKey = navigatorKey;

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'global navigator demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: const Home(),
      themeMode: ThemeMode.light,
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  GlobalNavigator.snackbar(
                    'title',
                    'message',
                    margin: EdgeInsets.zero,
                    isDismissible: false,
                  );
                },
                child: const Text('Snackbar'),
              ),
              ElevatedButton(
                onPressed: () {
                  GlobalNavigator.bottomSheet(
                    const SizedBox(
                      height: 200,
                      child: Text('child'),
                    ),
                  );
                },
                child: const Text('bottom sheet'),
              ),
              ElevatedButton(
                onPressed: () {
                  GlobalNavigator.dialog(
                    Dialog(
                      child: Container(
                        height: 200,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
                child: const Text('dialog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
