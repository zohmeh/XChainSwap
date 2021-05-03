import 'package:flutter/material.dart';
import 'package:web_app_template/functions/functions.dart';
import '/provider/contractinteraction.dart';
import '../provider/loginprovider.dart';
import 'package:provider/provider.dart';
import '../routing/router.dart';
import '../services/navigation_service.dart';
import '../views/layout_template.dart';
import '../routing/route_names.dart';
import './locator.dart';

void main() async {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: LoginModel(),
        ),
        ChangeNotifierProvider.value(
          value: Paraswap(),
        ),
        ChangeNotifierProvider.value(
          value: Contractinteraction(),
        ),
      ],
      child: MaterialApp(
        title: 'DushiFolio',
        theme: ThemeData(
            errorColor: Colors.red,
            buttonColor: Colors.blueAccent,
            highlightColor: Colors.white,
            primaryColor: Colors.blueGrey[900], //Colors.grey[850],
            backgroundColor: Colors.blueGrey[600], //Colors.white,
            accentColor: Colors.purpleAccent,
            textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                headline5: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white),
                headline4: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold))),
        navigatorKey: locator<NavigationService>().navigatorKey,
        onGenerateRoute: generateRoute,
        initialRoute: HomeRoute,
        builder: (context, child) => LayoutTemplate(child: child),
      ),
    );
  }
}
