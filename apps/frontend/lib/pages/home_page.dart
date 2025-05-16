import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import 'result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final provider = context.read<AuditProvider>();

    await provider.startAudit(_controller.text.trim());

    setState(() => _loading = false);

    final auditId = provider.result?.auditId;
    if (!mounted) return;
    if (provider.error == null && auditId != null) {
      _controller.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(auditId: auditId),
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Audit')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Zadejte URL webové stránky pro audit:',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'URL',
                    hintText: 'https://example.com',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Vyplňte URL';
                    final uri = Uri.tryParse(val.trim());
                    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return 'Neplatné URL';
                    return null;
                  },
                  keyboardType: TextInputType.url,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Spustit audit'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
