import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audit_provider.dart';
import '../services/url_validator.dart';
import 'result_page.dart';
import '../widgets/footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _submit({bool force = false}) async {
    String input = UrlValidator.normalize(_controller.text);
    _controller.text = input;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final provider = context.read<AuditProvider>();

    await provider.startAudit(_controller.text.trim(), force: force);

    setState(() => _loading = false);

    final auditId = provider.result?.auditId;

    if (!mounted) return;
    if (provider.error == null && auditId != null) {
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
    final provider = context.watch<AuditProvider>();
    // Pozor: Tohle nastaví hodnotu při každém buildnutí,
    // ale jen pokud tam uživatel zrovna nepíše!
    final lastUrl = provider.lastAuditedUrl;
    if ((_controller.text.isEmpty || _controller.text != lastUrl) &&
        (lastUrl != null && lastUrl.isNotEmpty)) {
      // Pokud je pole prázdné nebo neodpovídá poslední URL, nastav hodnotu
      _controller.text = lastUrl;
    }

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
                  validator: UrlValidator.validate,
                  keyboardType: TextInputType.url,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _submit(),
                        child: const Text('Spustit audit'),
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}
