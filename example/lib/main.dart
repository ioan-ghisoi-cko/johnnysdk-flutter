import 'package:flutter/material.dart';
import 'package:johnnysdk_flutter/main.dart';
import 'dart:developer';

Future<void> main() async {
  try {
    final request = CardTokenizationRequest(
      type: "card",
      number: "4242424242424242",
      expiryMonth: 6,
      expiryYear: 2028,
    );

    var res = await Checkout.tokenizeCard(
        "pk_test_4296fd52-efba-4a38-b6ce-cf0d93639d8a", request);
    log('data: $res');
  } on UnauthorizedError catch (exception) {
    log('UnauthorizedError data: $exception');
  } on InvalidDataError catch (exception) {
    log('InvalidDataError data: $exception.requestId');
  } catch (error) {
    log('final data: $error');
  }

  runApp(
    MaterialApp(
      home: LoginScreen(),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Salezrobot",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'HelveticaNeue',
            ),
          ),
        ),
        body: Center(child: null),
      ),
    );
  }
}
