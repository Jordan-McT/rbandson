import 'package:flutter/material.dart';
import '/auth/base_auth_user_provider.dart';
import '/index.dart';
import '/main.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/settings/authenticate_user_widget.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;

    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? const NavBarPage() : const LoginWidget(),
      routes: [
        GoRoute(
          name: '_initialize',
          path: '/',
          builder: (context, state) =>
              appStateNotifier.loggedIn ? const NavBarPage() : const LoginWidget(),
        ),
        GoRoute(
          name: 'Landing',
          path: '/landing',
          builder: (context, state) => const NavBarPage(
            initialPage: 'Landing',
          ),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
        GoRoute(
          name: 'Login',
          path: '/login',
          builder: (context, state) => const LoginWidget(),
        ),
        GoRoute(
          name: 'Schedule',
          path: '/schedule',
          builder: (context, state) => const NavBarPage(
            initialPage: 'Schedule',
          ),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
        GoRoute(
          name: 'Delivery',
          path: '/delivery',
          builder: (context, state) => const NavBarPage(
            initialPage: 'Delivery',
          ),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
        GoRoute(
          name: 'Camera',
          path: '/camera',
          builder: (context, state) => const NavBarPage(
            initialPage: 'Camera',
          ),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
        GoRoute(
          name: 'Register',
          path: '/register',
          builder: (context, state) => const RegisterWidget(),
        ),
        GoRoute(
          name: 'Settings',
          path: '/settings',
          builder: (context, state) => const NavBarPage(
            initialPage: 'Settings',
          ),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
        GoRoute(
          name: 'AuthenticateUser',
          path: '/authenticateUser',
          builder: (context, state) => const AuthenticateUserWidget(),
          redirect: (context, state) => appStateNotifier.loggedIn ? null : '/login',
        ),
      ],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/'); // Ensures it returns to NavBarPage when stack is empty
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}
