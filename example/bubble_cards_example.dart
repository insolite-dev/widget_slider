import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:widget_slider/widget_slider.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Home(),
      theme: ThemeData.dark(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = SliderController();
  final indexes = List.generate(10, (index) => index+1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WidgetSlider(
          controller: controller,
          itemCount: indexes .length,
          onMove: (i) {/*...*/},
          itemBuilder: (context, index, activeIndex) {
            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                if (index == activeIndex) return;
                await controller.moveTo?.call(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: index == activeIndex ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: index == activeIndex
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    indexes[index].toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
