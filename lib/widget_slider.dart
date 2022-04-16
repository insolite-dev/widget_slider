library widget_slider;

import 'package:flutter/material.dart';
import 'package:widget_slider/controller.dart';

/// A simple wrapper widget, used to generate size of WidgetSlider.
///
/// TODO: Provide example ...
class _FlexdSizedBox extends StatelessWidget {
  final Widget? child;
  final double? aspectRatio;
  final double? fixedSize;

  const _FlexdSizedBox({Key? key, this.child, this.aspectRatio, this.fixedSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fixedSize != null) return SizedBox(height: fixedSize, child: child);
    return AspectRatio(aspectRatio: aspectRatio ?? 1, child: child);
  }
}

/// A simple carousel type component-slider widget for Flutter.
class WidgetSlider extends StatefulWidget {
  /// Length of items that'd be built via [itemBuilder].
  final int itemCount;

  /// Widget generator of the list. Generated widgets are represented as [PageView] pages.
  ///
  /// First index is each elements real index, but second index is active page's(item's) index.
  final Widget Function(BuildContext, int, int) itemBuilder;

  /// A function to execute on each page move.
  /// {i} represents the index of moved page.
  final Function(int i)? onMove;

  /// A external controller to manipulate widget from outside of it.
  ///
  /// next()    | navigates to next(current+1) item.
  /// back()    | navigates to back(current-1) item.
  /// moveTo(i) | navigates to item at given index(i).
  final SliderController? controller;

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
    this.controller,
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
  State<StatefulWidget> createState() => _WidgetSliderState(controller);
}

class _WidgetSliderState extends State<WidgetSlider> {
  _WidgetSliderState(SliderController? controller) {
    if (controller == null) return;
    _controller = controller;

    controller.moveTo = moveTo;
    controller.moveToNext = moveToNext;
    controller.moveToPrevious = moveToPrevious;
  }

  int currentPage = 0;
  SliderController _controller = SliderController();
  late PageController pageController;

  @override
  void initState() {
    _setPageController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetSlider oldWidget) {
    _setPageController();
    super.didUpdateWidget(oldWidget);
  }

  // Closure(callback) of controller's moveTo function.
  Future<void> moveTo(i) async {
    return await pageController.animateToPage(
      i,
      duration: _controller.duration,
      curve: _controller.curve,
    );
  }

  // Closure(callback) of controller's moveToNext function.
  Future<void> moveToNext() async {
    return await pageController.nextPage(
      duration: _controller.duration,
      curve: _controller.curve,
    );
  }

  // Closure(callback) of controller's moveToPrevious function.
  Future<void> moveToPrevious() async {
    return await pageController.previousPage(
      duration: _controller.duration,
      curve: _controller.curve,
    );
  }

  PageController _setPageController() {
    pageController = PageController(
      initialPage: currentPage,
      viewportFraction: widget.proximity,
    );

    return pageController;
  }

  // Generates a valid scale for each item.
  double _generateScale(BuildContext context, int index, Size size) {
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
          child: widget.itemBuilder(context, i, currentPage),
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            final scale = _generateScale(context, i, size);

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
