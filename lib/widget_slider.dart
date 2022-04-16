library widget_slider;

import 'package:flutter/material.dart';

/// A simple carousel type component-slider widget for Flutter.
class WidgetSlider extends StatefulWidget {
  /// Length of items that'd be built via [itemBuilder].
  final int itemCount;

  /// Widget generator of the list. Generated widgets are represented as [PageView] pages.
  ///
  /// The argument [isActive] represents the [index]'s level(is main or not).
  final Widget Function(BuildContext, int, bool isActive) itemBuilder;

  /// A function to execute on each page move.
  /// {i} represents the index of moved page.
  final Function(int i)? onMove;

  /// The proximity between items.
  /// Value should be given as basic representation of percentages from (0 to 1) as
  /// | 0.1 -> 10%
  /// | 0.2 -> 20%
  /// ...
  ///
  /// If unset, defaults to the [0.5] -> 50%
  final double proximity;

  /// Decides differences of active & non-active item sizes .
  /// Value should be given as basic representation of percentages from (0 to 1) as
  /// | 0.1 -> 10%
  /// | 0.2 -> 20%
  /// ...
  ///
  ///           s:1
  ///  0.5   ╭────────╮   0.5
  /// ╭───╮  │        │  ╭───╮
  /// │ 6 │  │   47   │  │ 7 │
  /// ╰───╯  │        │  ╰───╯
  ///        ╰────────╯
  ///
  /// If unset, defaults to [0.5](non-active item will 50% smaller than active one).
  /// If set to [null], size distinction animation will be disabled.
  final double? sizeDistinction;

  /// The scroll direction of list widget.
  ///
  /// If unset, defaults to the [Axis.horizontal].
  final Axis scrollDirection;

  /// Ratio is of whole list widget.
  ///
  /// If unset, defaults to the -> [2].
  final double aspectRatio;

  /// Concrete fixed size for whole list widget.
  ///
  /// If not null, [aspectRatio]'s value will be ignored.
  final double? fixedSize;

  /// Animation curve style of widget's distinction.
  ///
  /// If unset defaults to the [Curves.easeOut].
  final Curve transformCurve;

  /// Reverse initializes list as reversed.
  /// [1, 2, 3] --> [3, 2, 1] (But remains at same page index(0)).
  ///
  /// If unset, defaults to the [false].
  final bool reverse;

  /// Enables/Disables snapping physics animation of widget.
  ///
  /// If unset, defaults to the [true](enabled).
  final bool pageSnapping;

  /// TODO: implement functionality to the widget.
  ///
  /// Enables/Disables infinite scrolling of list widget.
  /// If set, itemCount value will be ignored,
  /// Note: infinite scroll functionality could be enabled by setting [itemCount] to `null`.
  ///
  /// If unset, defaults to the [false](disabled).
  final bool infiniteScroll;

  const WidgetSlider({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.onMove,
    this.proximity = .5,
    this.sizeDistinction = 0.5,
    this.scrollDirection = Axis.horizontal,
    this.aspectRatio = 2,
    this.fixedSize,
    this.transformCurve = Curves.easeOut,
    this.reverse = false,
    this.pageSnapping = true,
    this.infiniteScroll = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WidgetSliderState();
}

class _WidgetSliderState extends State<WidgetSlider> {
  int currentPage = 0;
  late PageController pageController;

  @override
  void initState() {
    setPageController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetSlider oldWidget) {
    setPageController();
    super.didUpdateWidget(oldWidget);
  }

  PageController setPageController() {
    pageController = PageController(
      initialPage: currentPage,
      viewportFraction: widget.proximity,
    );

    return pageController;
  }

  // Generates a valid scale for each item.
  double generateScale(BuildContext context, int index, Size size) {
    if (widget.sizeDistinction == null) return 1;

    final offset = pageController.page! - index;
    final ratio = (1 - (widget.sizeDistinction! * offset.abs())).clamp(0, 1);

    return widget.transformCurve.transform(ratio.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return _FlexdSizedBox(
      fixedSize: widget.fixedSize,
      aspectRatio: widget.aspectRatio,
      child: PageView.builder(
        controller: pageController,
        reverse: widget.reverse,
        itemCount: widget.itemCount,
        pageSnapping: widget.pageSnapping,
        scrollDirection: widget.scrollDirection,
        onPageChanged: (i) {
          currentPage = i;
          widget.onMove?.call(i);
        },
        itemBuilder: (context, i) => AnimatedBuilder(
          // TODO: [Fix Page value is only available after content dimensions are established]. error
          animation: pageController,
          child: widget.itemBuilder(context, i, currentPage == i),
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            final scale = generateScale(context, i, size);

            return Transform.scale(
              scale: scale,
              child: Builder(
                builder: (context) {
                  if (widget.scrollDirection == Axis.horizontal) {
                    return SizedBox(child: child, width: scale * size.width);
                  }

                  return SizedBox(child: child, height: size.height);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// A simple wrapper widget, used to generate size of WidgetSlider.
class _FlexdSizedBox extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  final double? fixedSize;

  const _FlexdSizedBox({
    Key? key,
    required this.child,
    required this.aspectRatio,
    this.fixedSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fixedSize != null) return SizedBox(height: fixedSize, child: child);
    return AspectRatio(aspectRatio: aspectRatio, child: child);
  }
}

