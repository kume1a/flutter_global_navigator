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
      navigatorObservers: <NavigatorObserver>[
        GNObserver(),
      ],
      title: 'global navigator demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      routes: {
        'test': (_) => const Scaffold(
              body: Center(
                child: Text('test'),
              ),
            ),
        '/': (_) => const Home(),
      },
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
                onPressed: () async {
                  for (int i = 0; i < 3; ++i) {
                    GlobalNavigator.dialog(
                      Dialog(
                        child: Container(
                          height: 200,
                          color: Colors.primaries[i],
                        ),
                      ),
                    );
                  }

                  for (int i = 0; i < 3; ++i) {
                    GlobalNavigator.snackbar('title', 'message');
                  }
                  await Future<void>.delayed(const Duration(seconds: 1));
                  await GlobalNavigator.closeAllOverlays();
                  GlobalNavigator.pushNamed('test');
                  for (int i = 0; i < 3; ++i) {
                    GlobalNavigator.snackbar('on another page', 'message');
                  }
                },
                child: const Text('test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
