import 'dart:async';
import 'package:flutter/material.dart';

import '../navigation/route_observer.dart';
import 'bgm_controller.dart';

mixin HomeBgmRouteMixin<T extends StatefulWidget> on State<T>, RouteAware {
  bool _subscribedToRouteObserver = false;

  void playHomeBgm() {
    unawaited(BgmController.instance.playScene(BgmScene.home));
  }

  @override
  void initState() {
    super.initState();
    playHomeBgm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_subscribedToRouteObserver) return;

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      _subscribedToRouteObserver = true;
    }
  }

  @override
  void didPopNext() {
    // Called when a page above this one is popped.
    playHomeBgm();
  }

  @override
  void dispose() {
    if (_subscribedToRouteObserver) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }
}