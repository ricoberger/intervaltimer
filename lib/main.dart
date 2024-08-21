import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'package:intervaltimer/timers_list.dart';
import 'package:intervaltimer/timers_repository.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimersRepository()),
      ],
      child: MaterialApp(
        title: 'Interval Timer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xff171f2c),
            onPrimary: Colors.white,
            secondary: Color(0xff171f2c),
            onSecondary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            surface: Color(0xff171f2c),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xff171f2c),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          tooltipTheme: const TooltipThemeData(
            padding: EdgeInsets.all(8),
            preferBelow: false,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            decoration: BoxDecoration(
              color: Color(0xff171f2c),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const TimersList(),
      ),
    );
  }
}
