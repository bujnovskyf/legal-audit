import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audit_provider.dart';
import 'pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 34,
        letterSpacing: -1.2,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.8,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: -0.2,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );

    return ChangeNotifierProvider<AuditProvider>(
      create: (_) => AuditProvider(),
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Legal Audit',
        locale: _locale,
        home: HomePage(onLocaleChange: setLocale),
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF3F4F6),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF22C55E),
            brightness: Brightness.light,
            primary: const Color(0xFF22C55E),
            secondary: const Color(0xFF15803D),
            surface: Colors.white,
            error: const Color(0xFFF43F5E),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF18181B),
            onError: Colors.white,
          ),
          textTheme: textTheme,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFA3A3A3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              elevation: 6,
              shadowColor: const Color(0x3322C55E),
            ),
          ),
          cardTheme: CardTheme(
            color: Colors.white,
            elevation: 3,
            shadowColor: Colors.black.withAlpha((0.07 * 255).round()),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF18181B),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: const Color(0xFF18181B),
              letterSpacing: -0.8,
            ),
          ),
        ),
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
