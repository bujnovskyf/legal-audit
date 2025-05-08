// Result page: displays audit results.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../widgets/audit_card.dart';

class ResultPage extends StatefulWidget {
  final String url;
  const ResultPage({Key? key, required this.url}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AuditProvider>(context, listen: false).runAudit(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Results')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : AuditCard(result: provider.result!),
    );
  }
}
