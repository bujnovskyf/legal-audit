// Defines the root widget and app-level configuration.
import 'package:flutter/material.dart';
import 'providers/audit_provider.dart';
import 'pages/home_page.dart';
import 'package:provider/provider.dart';

class LegalAuditApp extends StatelessWidget {
  const LegalAuditApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuditProvider(),
      child: MaterialApp(
        title: 'Legal Audit',
        home: HomePage(),
      ),
    );
  }
}
