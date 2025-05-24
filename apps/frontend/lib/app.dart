import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audit_provider.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LegalAuditApp extends StatefulWidget {
  const LegalAuditApp({super.key});

  @override
  State<LegalAuditApp> createState() => _LegalAuditAppState();
}

class _LegalAuditAppState extends State<LegalAuditApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuditProvider>(
      create: (_) => AuditProvider(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Legal Audit',
        locale: _locale,
        home: HomePage(onLocaleChange: setLocale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('cs'),
        ],
      ),
    );
  }
}
