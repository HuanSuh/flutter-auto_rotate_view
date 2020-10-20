import 'package:auto_rotate_view/auto_rotate_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Auto Rotate View Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AutoRotateViewExample(),
    ),
  );
}

class AutoRotateViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Rotate View'),
      ),
      body: Column(
        children: [
          AutoRotateView<String>(
            items: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
            builder: (ctx, item) {
              return Text(item ?? '');
            },
            direction: RotateDirection.LEFT,
          ),
          AutoRotateView<String>(
            items: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
            builder: (ctx, item) {
              return Text(item ?? '');
            },
            direction: RotateDirection.UP,
            transitionHeight:
                Theme.of(context).textTheme.bodyText1.fontSize * 2,
          ),
          AutoRotateView<String>(
            items: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
            builder: (ctx, item) {
              return Text(item ?? '');
            },
            direction: RotateDirection.UP,
            crossAxisAlignment: CrossAxisAlignment.center,
            animateDuration: Duration(seconds: 1),
            duration: Duration(seconds: 1),
          ),
        ],
      ),
    );
  }
}
