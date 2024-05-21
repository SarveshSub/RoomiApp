import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Payments',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
