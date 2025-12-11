// lib/utils/animation_presets.dart

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AnimationPresets {
  AnimationPresets._();

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve sharpCurve = Curves.easeOutExpo;

  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<double> fadeOut(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<Offset> slideFromBottom(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<Offset> slideFromTop(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<Offset> slideFromLeft(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<Offset> slideFromRight(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<double> scaleIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: bounceCurve),
    );
  }

  static Animation<double> scaleOut(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<double> buttonPress(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: controller, curve: defaultCurve),
    );
  }

  static Animation<double> pulse(AnimationController controller) {
    return Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  static Animation<double> rotate(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
  }

  static Animation<double> shake(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear),
    );
  }

  static Animation<double> bounce(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.bounceOut),
    );
  }

  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: animation,
      alignment: alignment,
      child: child,
    );
  }

  static Widget slideTransition({
    required Animation<Offset> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }

  static Widget combinedFadeSlide({
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }

  static Widget combinedFadeScale({
    required Animation<double> fadeAnimation,
    required Animation<double> scaleAnimation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }

  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration ?? AppConstants.mediumDuration,
    );
  }

  static Future<void> playSequence(
      List<AnimationController> controllers) async {
    for (final controller in controllers) {
      await controller.forward();
    }
  }

  static Future<void> reverseSequence(
      List<AnimationController> controllers) async {
    for (final controller in controllers.reversed) {
      await controller.reverse();
    }
  }
}
