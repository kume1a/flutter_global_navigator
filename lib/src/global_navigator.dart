import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'bottom_sheet/bottom_sheet_route.dart';
import 'dialog/dialog_route.dart';
import 'simple_route_identifier.dart';
import 'snackbar/snackbar.dart';
import 'snackbar/snackbar_controller.dart';
import 'utils/listx.dart';

/// It replaces the Flutter Navigator, but needs no context.
/// You can to use navigator.push(YourRoute()) rather
/// Navigator.push(context, YourRoute());

typedef RoutePredicate = bool Function(SimpleRouteIdentifier route);

class GlobalNavigator {
  static GlobalKey<NavigatorState>? navigatorKey;
  static Curve defaultTransitionCurve = Curves.easeOutQuad;
  static Duration defaultTransitionDuration = const Duration(milliseconds: 300);

  static List<SimpleRouteIdentifier> currentStack =
      List<SimpleRouteIdentifier>.empty(growable: true);

  static SimpleRouteIdentifier? get currentRouteIdentifier =>
      currentStack.isNotEmpty ? currentStack.last : null;

  /// give access to current Overlay Context
  static BuildContext? get overlayContext {
    BuildContext? overlay;
    navigatorKey?.currentState?.overlay?.context.visitChildElements((Element e) => overlay = e);
    return overlay;
  }

  static BuildContext? get context => navigatorKey?.currentContext;

  /// give access to Theme.of(context)
  static ThemeData get theme {
    ThemeData _theme = ThemeData.fallback();
    if (navigatorKey?.currentContext != null) {
      _theme = Theme.of(navigatorKey!.currentContext!);
    }
    return _theme;
  }

  static Future<bool> maybePop<T extends Object?>({
    T? result,
  }) async {
    if (currentStack.isNotEmpty) {
      currentStack.removeLast();
    }

    final bool? r = await navigatorKey?.currentState?.maybePop(result);
    return r ?? false;
  }

  @optionalTypeArgs
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool allowLastDuplicate = false,
  }) async {
    if (!allowLastDuplicate &&
        currentRouteIdentifier != null &&
        currentRouteIdentifier?.name == routeName) {
      return null;
    }

    currentStack.add(SimpleRouteIdentifier(name: routeName, args: arguments));

    return navigatorKey?.currentState?.pushNamed(routeName, arguments: arguments);
  }

  @optionalTypeArgs
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
    bool allowLastDuplicate = false,
  }) async {
    if (!allowLastDuplicate &&
        currentRouteIdentifier != null &&
        currentRouteIdentifier?.name == routeName) {
      return null;
    }

    if (currentStack.isNotEmpty) {
      currentStack.removeLast();
    }
    currentStack.add(SimpleRouteIdentifier(name: routeName, args: arguments));

    return navigatorKey?.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  void popUntil(String routeName) {
    currentStack.popUntil((SimpleRouteIdentifier e) => e.name == routeName);

    navigatorKey?.currentState
        ?.popUntil((Route<dynamic> route) => route.settings.name == routeName);
  }

  @optionalTypeArgs
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    String tillRouteName, {
    Object? arguments,
    bool allowLastDuplicate = false,
  }) async {
    if (!allowLastDuplicate &&
        currentRouteIdentifier != null &&
        currentRouteIdentifier?.name == newRouteName) {
      return null;
    }

    currentStack.popUntil((SimpleRouteIdentifier e) => e.name == tillRouteName);
    currentStack.add(SimpleRouteIdentifier(name: newRouteName, args: arguments));

    return navigatorKey?.currentState?.pushNamedAndRemoveUntil<T>(
      newRouteName,
      (Route<dynamic> route) => route.settings.name != tillRouteName,
      arguments: arguments,
    );
  }

  @optionalTypeArgs
  static Future<T?> pushNamedAndRemoveAll<T extends Object?>(
    String newRouteName, {
    Object? arguments,
    bool allowLastDuplicate = false,
  }) async {
    if (!allowLastDuplicate &&
        currentRouteIdentifier != null &&
        currentRouteIdentifier?.name == newRouteName) {
      return null;
    }

    currentStack.assign(SimpleRouteIdentifier(name: newRouteName, args: arguments));

    return navigatorKey?.currentState?.pushNamedAndRemoveUntil<T>(
      newRouteName,
      (_) => false,
      arguments: arguments,
    );
  }

  static Future<void> closeCurrentSnackbar() async => SnackbarController.closeCurrentSnackbar();

  static Future<void> closeAllSnackbars() async => SnackbarController.cancelAllSnackbars();

  static bool get isSnackBarBeingShown => SnackbarController.isSnackbarBeingShown;

  static SnackbarController rawSnackbar({
    String? title,
    String? message,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool instantInit = true,
    bool shouldIconPulse = true,
    double? maxWidth,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = const EdgeInsets.all(16),
    double borderRadius = 0.0,
    Color? borderColor,
    double borderWidth = 1.0,
    Color backgroundColor = const Color(0xFF303030),
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    Widget? mainButton,
    OnTap? onTap,
    Duration? duration = const Duration(seconds: 3),
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    bool showProgressIndicator = false,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackPosition snackPosition = SnackPosition.bottom,
    SnackStyle snackStyle = SnackStyle.floating,
    Curve forwardAnimationCurve = Curves.easeOutCirc,
    Curve reverseAnimationCurve = Curves.easeOutCirc,
    Duration animationDuration = const Duration(seconds: 1),
    SnackbarStatusCallback? snackbarStatus,
    double barBlur = 0.0,
    double overlayBlur = 0.0,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final GNSnackBar getSnackBar = GNSnackBar(
      snackbarStatus: snackbarStatus,
      title: title,
      message: message,
      titleText: titleText,
      messageText: messageText,
      snackPosition: snackPosition,
      borderRadius: borderRadius,
      margin: margin,
      duration: duration,
      barBlur: barBlur,
      backgroundColor: backgroundColor,
      icon: icon,
      shouldIconPulse: shouldIconPulse,
      maxWidth: maxWidth,
      padding: padding,
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle,
      forwardAnimationCurve: forwardAnimationCurve,
      reverseAnimationCurve: reverseAnimationCurve,
      animationDuration: animationDuration,
      overlayBlur: overlayBlur,
      overlayColor: overlayColor,
      userInputForm: userInputForm,
    );

    final SnackbarController controller = SnackbarController(getSnackBar);

    if (instantInit) {
      controller.show();
    } else {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }

  static SnackbarController showSnackbar(GNSnackBar snackbar) {
    final SnackbarController controller = SnackbarController(snackbar);
    controller.show();
    return controller;
  }

  static SnackbarController snackbar(
    String title,
    String message, {
    Color? colorText,
    Duration? duration = const Duration(seconds: 2),

    /// with instantInit = false you can put snackbar on initState
    bool instantInit = true,
    SnackPosition? snackPosition,
    Widget? titleText,
    Widget? messageText,
    Widget? icon,
    bool? shouldIconPulse,
    double? maxWidth,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    List<BoxShadow>? boxShadows,
    Gradient? backgroundGradient,
    TextButton? mainButton,
    OnTap? onTap,
    bool? isDismissible,
    bool? showProgressIndicator,
    DismissDirection? dismissDirection,
    AnimationController? progressIndicatorController,
    Color? progressIndicatorBackgroundColor,
    Animation<Color>? progressIndicatorValueColor,
    SnackStyle? snackStyle,
    Curve? forwardAnimationCurve,
    Curve? reverseAnimationCurve,
    Duration? animationDuration,
    double? barBlur,
    double? overlayBlur,
    SnackbarStatusCallback? snackbarStatus,
    Color? overlayColor,
    Form? userInputForm,
  }) {
    final GNSnackBar snackBar = GNSnackBar(
      snackbarStatus: snackbarStatus,
      titleText: titleText ??
          Text(
            title,
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
      messageText: messageText ??
          Text(
            message,
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
          ),
      snackPosition: snackPosition ?? SnackPosition.top,
      borderRadius: borderRadius ?? 15,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
      duration: duration,
      barBlur: barBlur ?? 7.0,
      backgroundColor: backgroundColor ?? Colors.grey.withOpacity(0.2),
      icon: icon,
      shouldIconPulse: shouldIconPulse ?? true,
      maxWidth: maxWidth,
      padding: padding ?? const EdgeInsets.all(16),
      borderColor: borderColor,
      borderWidth: borderWidth,
      leftBarIndicatorColor: leftBarIndicatorColor,
      boxShadows: boxShadows,
      backgroundGradient: backgroundGradient,
      mainButton: mainButton,
      onTap: onTap,
      isDismissible: isDismissible ?? true,
      dismissDirection: dismissDirection,
      showProgressIndicator: showProgressIndicator ?? false,
      progressIndicatorController: progressIndicatorController,
      progressIndicatorBackgroundColor: progressIndicatorBackgroundColor,
      progressIndicatorValueColor: progressIndicatorValueColor,
      snackStyle: snackStyle ?? SnackStyle.floating,
      forwardAnimationCurve: forwardAnimationCurve ?? Curves.easeOutCirc,
      reverseAnimationCurve: reverseAnimationCurve ?? Curves.easeOutCirc,
      animationDuration: animationDuration ?? const Duration(milliseconds: 500),
      overlayBlur: overlayBlur ?? 0.0,
      overlayColor: overlayColor ?? Colors.transparent,
      userInputForm: userInputForm,
    );

    final SnackbarController controller = SnackbarController(snackBar);

    if (instantInit) {
      controller.show();
    } else {
      //routing.isSnackbar = true;
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        controller.show();
      });
    }
    return controller;
  }

  static Future<T?> bottomSheet<T>(
    Widget bottomSheet, {
    Color? backgroundColor,
    double? elevation,
    bool persistent = true,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool? ignoreSafeArea,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    RouteSettings? settings,
    Duration? enterBottomSheetDuration,
    Duration? exitBottomSheetDuration,
  }) async {
    if (navigatorKey == null) {
      return null;
    }

    return Navigator.of(overlayContext!, rootNavigator: useRootNavigator).push(
      ModalBottomSheetRoute<T>(
        builder: (_) => bottomSheet,
        isPersistent: persistent,
        theme: Theme.of(navigatorKey!.currentContext!),
        isScrollControlled: isScrollControlled,
        barrierLabel:
            MaterialLocalizations.of(navigatorKey!.currentContext!).modalBarrierDismissLabel,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        removeTop: ignoreSafeArea ?? true,
        clipBehavior: clipBehavior,
        isDismissible: isDismissible,
        modalBarrierColor: barrierColor,
        settings: settings,
        enableDrag: enableDrag,
        enterBottomSheetDuration: enterBottomSheetDuration ?? const Duration(milliseconds: 150),
        exitBottomSheetDuration: exitBottomSheetDuration ?? const Duration(milliseconds: 100),
      ),
    );
  }

  /// Show a dialog.
  /// You can pass a [transitionDuration] and/or [transitionCurve],
  /// overriding the defaults when the dialog shows up and closes.
  /// When the dialog closes, uses those animations in reverse.
  static Future<T?> dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
  }) {
    assert(
      debugCheckHasMaterialLocalizations(
        (navigatorKey ?? GlobalNavigator.navigatorKey)!.currentContext!,
      ),
    );

    //  final theme = Theme.of(context, shadowThemeOnly: true);
    final ThemeData theme =
        Theme.of((navigatorKey ?? GlobalNavigator.navigatorKey)!.currentContext!);
    return generalDialog<T>(
      pageBuilder: (
        BuildContext buildContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        final Widget pageChild = widget;
        Widget dialog = Builder(
          builder: (BuildContext context) {
            return Theme(data: theme, child: pageChild);
          },
        );
        if (useSafeArea) {
          dialog = SafeArea(child: dialog);
        }
        return dialog;
      },
      barrierDismissible: barrierDismissible,
      barrierLabel:
          MaterialLocalizations.of((navigatorKey ?? GlobalNavigator.navigatorKey)!.currentContext!)
              .modalBarrierDismissLabel,
      barrierColor: barrierColor ?? const Color(0x4D000000),
      transitionDuration: transitionDuration ?? defaultTransitionDuration,
      transitionBuilder: (
        _,
        Animation<double> animation,
        __,
        Widget child,
      ) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: transitionCurve ?? defaultTransitionCurve,
          ),
          child: child,
        );
      },
      navigatorKey: navigatorKey,
      routeSettings: routeSettings ?? RouteSettings(arguments: arguments, name: name),
    );
  }

  /// Api from showGeneralDialog with no context
  static Future<T?> generalDialog<T>({
    required RoutePageBuilder pageBuilder,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x80000000),
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder? transitionBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
    RouteSettings? routeSettings,
  }) {
    assert(!barrierDismissible || barrierLabel != null);
    final NavigatorState nav = navigatorKey?.currentState ??
        Navigator.of(
          overlayContext!,
          rootNavigator: true,
        ); //overlay context will always return the root navigator
    return nav.push<T>(
      GNDialogRoute<T>(
        pageBuilder: pageBuilder,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        transitionDuration: transitionDuration,
        transitionBuilder: transitionBuilder,
        settings: routeSettings,
      ),
    );
  }

  /// Custom UI Dialog.
  static Future<T?> defaultDialog<T>({
    String title = 'Alert',
    EdgeInsetsGeometry? titlePadding,
    TextStyle? titleStyle,
    Widget? content,
    EdgeInsetsGeometry? contentPadding,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    VoidCallback? onCustom,
    Color? cancelTextColor,
    Color? confirmTextColor,
    String? textConfirm,
    String? textCancel,
    String? textCustom,
    Widget? confirm,
    Widget? cancel,
    Widget? custom,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Color? buttonColor,
    String middleText = 'Dialog made in 3 lines of code',
    TextStyle? middleTextStyle,
    double radius = 20.0,
    //   ThemeData themeData,
    List<Widget>? actions,

    // onWillPop Scope
    WillPopCallback? onWillPop,

    // the navigator used to push the dialog
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    final bool leanCancel = onCancel != null || textCancel != null;
    final bool leanConfirm = onConfirm != null || textConfirm != null;
    actions ??= <Widget>[];

    if (cancel != null) {
      actions.add(cancel);
    } else {
      if (leanCancel) {
        actions.add(
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: buttonColor ?? theme.colorScheme.secondary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            onPressed: () {
              onCancel?.call();
              navigatorKey?.currentState?.pop();
            },
            child: Text(
              textCancel ?? 'Cancel',
              style: TextStyle(color: cancelTextColor ?? theme.colorScheme.secondary),
            ),
          ),
        );
      }
    }
    if (confirm != null) {
      actions.add(confirm);
    } else {
      if (leanConfirm) {
        actions.add(
          TextButton(
            style: TextButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: buttonColor ?? theme.colorScheme.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(
              textConfirm ?? 'Ok',
              style: TextStyle(color: confirmTextColor ?? theme.backgroundColor),
            ),
            onPressed: () {
              onConfirm?.call();
            },
          ),
        );
      }
    }

    final Widget baseAlertDialog = AlertDialog(
      titlePadding: titlePadding ?? const EdgeInsets.all(8),
      contentPadding: contentPadding ?? const EdgeInsets.all(8),

      backgroundColor: backgroundColor ?? theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(radius))),
      title: Text(title, textAlign: TextAlign.center, style: titleStyle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          content ?? Text(middleText, textAlign: TextAlign.center, style: middleTextStyle),
          const SizedBox(height: 16),
          ButtonTheme(
            minWidth: 78.0,
            height: 34.0,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          )
        ],
      ),
      // actions: actions, // ?? <Widget>[cancelButton, confirmButton],
      buttonPadding: EdgeInsets.zero,
    );

    return dialog<T>(
      onWillPop != null
          ? WillPopScope(
              onWillPop: onWillPop,
              child: baseAlertDialog,
            )
          : baseAlertDialog,
      barrierDismissible: barrierDismissible,
      navigatorKey: navigatorKey,
    );
  }
}
