import 'dart:async';
import 'package:dart_meteor/dart_meteor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import '../providers/printer_provider.dart';
import '../providers/setting_provider.dart';
import '../router/app_router.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/login_form_provider.dart';
import '../providers/my_profile_provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../storages/connection_storage.dart';
import '../utils/theme/theme.dart';

MeteorClient meteor = MeteorClient.connect(url: '');

class AppScreen extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  const AppScreen({
    super.key,
    required this.sharedPreferences,
  });

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late String? ipAddress;
  late AppProvider appProvider;
  late ThemeProvider themeProvider;
  late RouteProvider routeProvider;
  late AuthProvider authProvider;
  late StreamSubscription<bool> authSubscription;
  late MyProfileProvider myProfileProvider;
  late LoginFormProvider loginFormProvider;
  late SettingProvider settingProvider;
  late PrinterProvider printerProvider;

  @override
  void initState() {
    appProvider = AppProvider(widget.sharedPreferences);
    themeProvider = ThemeProvider();
    routeProvider = RouteProvider();
    authProvider = AuthProvider();
    authSubscription = authProvider.onAuthStateChange.listen(onAuthStateChange);
    myProfileProvider = MyProfileProvider();
    loginFormProvider = LoginFormProvider(widget.sharedPreferences);
    settingProvider = SettingProvider();
    printerProvider = PrinterProvider();
    onStartUp();
    super.initState();
  }

  void onAuthStateChange(bool login) {
    appProvider.loginState = login;
  }

  void onStartUp() async {
    ipAddress = await ConnectionStorage().getIpAddress();
    if (ipAddress != null) {
      meteor = MeteorClient.connect(url: 'http://$ipAddress');
    }
    await appProvider.onAppStart();
    await themeProvider.initState();
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(create: (_) => appProvider),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
        ChangeNotifierProvider<RouteProvider>(create: (_) => routeProvider),
        Provider<AppRouter>(create: (_) => AppRouter(appProvider)),
        ChangeNotifierProvider<AuthProvider>(create: (_) => authProvider),
        ChangeNotifierProvider<MyProfileProvider>(
            create: (_) => myProfileProvider),
        ChangeNotifierProvider<LoginFormProvider>(
            create: (_) => loginFormProvider),
        ChangeNotifierProvider<SettingProvider>(create: (_) => settingProvider),
        ChangeNotifierProvider<PrinterProvider>(create: (_) => printerProvider)
      ],
      child: Builder(
        builder: (context) {
          final GoRouter goRouter = context.read<AppRouter>().router;
          return Consumer<ThemeProvider>(builder: (context, state, child) {
            return ToastificationWrapper(
              child: MaterialApp.router(
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                localizationsDelegates: [
                  ...context.localizationDelegates,
                  FormBuilderLocalizations.delegate,
                ],
                title: "Flutter Template",
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: state.themeMode,
                routerConfig: goRouter,
              ),
            );
          });
        },
      ),
    );
  }
}
