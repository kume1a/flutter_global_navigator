import 'package:flutter/widgets.dart';

import 'bottom_sheet/bottom_sheet_route.dart';
import 'constants.dart';
import 'dialog/dialog_route.dart';
import 'global_navigator.dart';

String? _extractRouteName(Route<dynamic>? route) {
  if (route?.settings.name != null) {
    return route!.settings.name;
  }

  if (route is GNDialogRoute) {
    return '$kDialogRoutePrefix ${route.hashCode}';
  }

  if (route is GNBottomSheetRoute) {
    return '$kBottomSheetRoutePrefix ${route.hashCode}';
  }

  return null;
}

class GNObserver extends NavigatorObserver {
  GNObserver([this.routing]);

  final Function(Routing?)? routing;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final _RouteData newRoute = _RouteData.ofRoute(previousRoute);

    GlobalNavigator.routing.update((Routing value) {
      if (previousRoute is PageRoute) {
        value.current = _extractRouteName(previousRoute) ?? '';
        value.previous = newRoute.name ?? '';
      } else if (value.previous.isNotEmpty) {
        value.current = value.previous;
      }

      value.args = previousRoute?.settings.arguments;
      value.route = previousRoute;
      value.isBack = true;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet;
      value.isDialog = newRoute.isDialog;
    });

    routing?.call(GlobalNavigator.routing);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final _RouteData newRoute = _RouteData.ofRoute(route);
    
    GlobalNavigator.routing.update((Routing value) {
      if (route is PageRoute) {
        value.current = newRoute.name ?? '';
      }
      final String? previousRouteName = _extractRouteName(previousRoute);
      if (previousRouteName != null) {
        value.previous = previousRouteName;
      }

      value.args = route.settings.arguments;
      value.route = route;
      value.isBack = false;
      value.removed = '';
      value.isBottomSheet = newRoute.isBottomSheet || (value.isBottomSheet ?? false);
      value.isDialog = newRoute.isDialog || (value.isDialog ?? false);
    });

    if (routing != null) {
      routing?.call(GlobalNavigator.routing);
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final String? routeName = _extractRouteName(route);
    final _RouteData currentRoute = _RouteData.ofRoute(route);

    GlobalNavigator.routing.update((Routing value) {
      value.route = previousRoute;
      value.isBack = false;
      value.removed = routeName ?? '';
      value.previous = routeName ?? '';
      value.isBottomSheet = currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });
    routing?.call(GlobalNavigator.routing);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final String? newName = _extractRouteName(newRoute);
    final String? oldName = _extractRouteName(oldRoute);
    final _RouteData currentRoute = _RouteData.ofRoute(oldRoute);
    
    GlobalNavigator.routing.update((Routing value) {
      if (newRoute is PageRoute) {
        value.current = newName ?? '';
      }

      value.args = newRoute?.settings.arguments;
      value.route = newRoute;
      value.isBack = false;
      value.removed = '';
      value.previous = '$oldName';
      value.isBottomSheet = currentRoute.isBottomSheet ? false : value.isBottomSheet;
      value.isDialog = currentRoute.isDialog ? false : value.isDialog;
    });

    routing?.call(GlobalNavigator.routing);
  }
}

class Routing {
  Routing({
    this.current = '',
    this.previous = '',
    this.args,
    this.removed = '',
    this.route,
    this.isBack,
    this.isBottomSheet,
    this.isDialog,
  });

  String current;
  String previous;
  dynamic args;
  String removed;
  Route<dynamic>? route;
  bool? isBack;
  bool? isBottomSheet;
  bool? isDialog;

  void update(void Function(Routing value) fn) {
    fn(this);
  }
}

class _RouteData {
  _RouteData({
    required this.name,
    required this.isBottomSheet,
    required this.isDialog,
  });

  factory _RouteData.ofRoute(Route<dynamic>? route) {
    return _RouteData(
      name: _extractRouteName(route),
      isDialog: route is GNDialogRoute,
      isBottomSheet: route is GNBottomSheetRoute,
    );
  }

  final bool isBottomSheet;
  final bool isDialog;
  final String? name;
}
