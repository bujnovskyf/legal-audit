// Purpose: Root widget and provider setup.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audit_provider.dart';
import 'pages/home_page.dart';

class LegalAuditApp extends StatelessWidget {
  const LegalAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuditProvider(),
      child: MaterialApp(
        title: 'Legal Audit',
        home: const HomePage(),
      ),
    );
  }
}