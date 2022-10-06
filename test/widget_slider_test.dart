//
// Copyright 2021-2022 present Insolite. All rights reserved.
// Use of this source code is governed by Apache 2.0 license
// that can be found in the LICENSE file.
//

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_slider/widget_slider.dart';

void main() {
  late Widget horizontalSlider, verticalSlider;
  late SliderController controller;

  final items = List.generate(5, (index) => 'Test $index');

  setUpAll(() {
    controller = SliderController();

    horizontalSlider = WidgetSlider(
      controller: controller,
      itemCount: items.length,
      onMove: (_) {},
      itemBuilder: (context, index, activeIndex) {
        final value = index == activeIndex ? 'active' : 'non-active';
        return Text(value, key: Key(value));
      },
    );

    verticalSlider = WidgetSlider(
      itemCount: items.length,
      scrollDirection: Axis.vertical,
      onMove: (_) {},
      itemBuilder: (context, index, activeIndex) {
        return Text(index == activeIndex ? 'active' : 'non-active');
      },
    );
  });

  group('[WidgetSlider]', () {
    testWidgets('should build horizontal-widget properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: horizontalSlider)),
      );

      // Stable widgets.
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsNWidgets(items.length + 3));
      expect(find.byType(Transform), findsNWidgets(8));
      expect(find.byType(Builder), findsNWidgets(items.length));
      expect(find.byType(SizedBox), findsNWidgets(2));

      // User provided.
      expect(find.byType(Text), findsNWidgets(2));

      // State actions.
      controller.moveToNext?.call();
      controller.moveToPrevious?.call();
      controller.moveTo?.call(items.length - 1);
    });

    testWidgets(
      'should build vertical-widget properly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: verticalSlider)),
        );

        // Stable widgets.
        expect(find.byType(PageView), findsOneWidget);
        expect(find.byType(AnimatedBuilder), findsNWidgets(items.length + 3));
        expect(find.byType(Transform), findsNWidgets(8));
        expect(find.byType(Builder), findsNWidgets(items.length));
        expect(find.byType(SizedBox), findsNWidgets(2));

        // User provided.
        expect(find.byType(Text), findsNWidgets(2));
      },
    );
  });
}
