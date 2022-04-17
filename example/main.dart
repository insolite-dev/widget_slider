import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widget_slider/widget_slider.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = SliderController(
    duration: const Duration(milliseconds: 600),
  );

  final images = const [
    'https://i.picsum.photos/id/816/200/300.jpg?hmac=4O5XSGjimzcjZYOXpVb_--v3rGzmS-3chmG2L1MS-mc',
    'https://i.picsum.photos/id/436/200/300.jpg?hmac=OuJRsPTZRaNZhIyVFbzDkMYMyORVpV86q5M8igEfM3Y',
    'https://i.picsum.photos/id/645/200/300.jpg?hmac=fiKW3Nj8r0CWJQY3S-kkeT8PAfvKhA8igd9GIRk41Yw',
    'https://i.picsum.photos/id/281/200/300.jpg?hmac=KCN8F5QTgxHdeQxLpZ5BOuUEVQEp8jAedlLSRERW7CY',
    'https://i.picsum.photos/id/816/200/300.jpg?hmac=4O5XSGjimzcjZYOXpVb_--v3rGzmS-3chmG2L1MS-mc',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WidgetSlider(
          fixedSize: 300,
          controller: controller,
          itemCount: images.length,
          itemBuilder: (context, index, activeIndex) {
            return CupertinoButton(
              onPressed: () async => await controller.moveTo?.call(index),
              child: Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(images[index]),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade50,
                      offset: const Offset(0, 8),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.grey.shade100,
                      offset: const Offset(0, 8),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
