import 'package:memorial_keeper/src/imports/core_imports.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    Widget current = _buildMaterialApp(context);
    current = AppPlatformScope(
      style: AppPlatformStyle.material,
      child: current,
    );
    return ScreenUtilWrapper(child: current);
  }


  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      title: 'memorial_keeper',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#0D5C46'),
      darkTheme: buildDarkTheme(primaryColorHex: '#10B981'),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        return current;
      },
    );
  }
}
