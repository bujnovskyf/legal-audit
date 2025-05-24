import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputForm extends StatefulWidget {
  final void Function(String) onSubmit;
  const InputForm({super.key, required this.onSubmit});

  @override
  State<InputForm> createState() => InputFormState();
}

class InputFormState extends State<InputForm> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardPadding = screenWidth < 600 ? 18 : 36;

    return Center(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: cardPadding,
            horizontal: cardPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.inputFormTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: const Color(0xFF18181B),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: l10n.websiteUrl,
                    hintText: l10n.websiteUrlHint,
                    prefixIcon: const Icon(Icons.link, color: Color(0xFF22C55E)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  validator: (val) => (val == null || val.isEmpty)
                      ? l10n.errorEnterUrl
                      : null,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(context),
                  autofillHints: const [AutofillHints.url],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.search_rounded, size: 22),
                          label: Text(
                            l10n.runAudit,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: () => _submit(context),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      await Future.delayed(const Duration(milliseconds: 350)); // Simulace latency UX
      widget.onSubmit(_controller.text.trim());
      setState(() => _loading = false);
    }
  }
}
