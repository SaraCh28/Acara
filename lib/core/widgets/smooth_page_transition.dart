import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class SmoothPageTransition extends StatelessWidget {
  final Widget child;
  final SharedAxisTransitionType transitionType;

  const SmoothPageTransition({
    Key? key,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SharedAxisTransition(
      transitionType: transitionType,
      animation: kAlwaysCompleteAnimation,
      secondaryAnimation: kAlwaysCompleteAnimation,
      child: child,
    );
  }
}

// Custom Page Route with smooth transitions
class SmoothPageRoute<T> extends PageRoute<T> {
  SmoothPageRoute({
    required this.builder,
    this.transitionType = SharedAxisTransitionType.horizontal,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;
  final SharedAxisTransitionType transitionType;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SharedAxisTransition(
      transitionType: transitionType,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

// Custom Page Transition Provider
class FadeThroughPageRoute<T> extends PageRoute<T> {
  FadeThroughPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

