// Purpose: Fetch and display audit results.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../widgets/audit_card.dart';

class ResultPage extends StatefulWidget {
  final String url;
  const ResultPage({super.key, required this.url});

  @override
  State<ResultPage> createState() => ResultPageState();
}

class ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuditProvider>().runAudit(widget.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Result')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : AuditCard(result: provider.result!),
    );
  }
}