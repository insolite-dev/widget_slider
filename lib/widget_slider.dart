library widget_slider;

import 'package:flutter/material.dart';
import 'package:widget_slider/controller.dart';

export 'package:widget_slider/controller.dart';

/// A simple wrapper widget, used to generate size of [WidgetSlider].
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

  /// Physics of the list widget.
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// If an explicit [ScrollBehavior] is provided to [scrollBehavior], the
  /// [ScrollPhysics] provided by that behavior will take precedence after
  /// [physics].
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether to add padding to both ends of the list.
  ///
  /// If this is set to true and [sizeDistinction] < 1.0, padding will be added
  /// such that the first and last child slivers will be in the center of
  /// the viewport when scrolled all the way to the start or end, respectively.
  ///
  /// If [sizeDistinction] >= 1.0, this property has no effect.
  ///
  /// If unset, defaults to the [true].
  final bool padEnds;

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
    this.physics,
    this.padEnds = true,
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

  double currentPage = 0;
  SliderController _controller = SliderController();
  late PageController pageController;

  @override
  void initState() {
    _reInitEssentials();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetSlider oldWidget) {
    _reInitEssentials();
    super.didUpdateWidget(oldWidget);
  }

  void _reInitEssentials() {
    pageController = PageController(
      initialPage: currentPage.round(),
      viewportFraction: widget.proximity,
    );

    // Used to avoid [Page value is only available after content dimensions are established] error.
    // Taking page's value via listener causes no error. Instead of [pageController.page] we use [currentPage]
    pageController.addListener(() {
      if (pageController.page == null) return;
      currentPage = pageController.page!;
    });
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

  // Generates a valid scale for each item.
  double _generateScale(int index, Size size) {
    if (widget.sizeDistinction == null) return 1;

    final offset = (currentPage - index).abs();
    final ratio = (1 - (widget.sizeDistinction! * offset)).clamp(0, 1);

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
        physics: widget.physics,
        padEnds: widget.padEnds,
        scrollDirection: widget.scrollDirection,
        onPageChanged: (i) => widget.onMove?.call(i),
        itemBuilder: (context, i) => AnimatedBuilder(
          animation: pageController,
          child: widget.itemBuilder(context, i, currentPage.round()),
          builder: (context, child) {
            final size = MediaQuery.of(context).size;
            final scale = _generateScale(i, size);

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
