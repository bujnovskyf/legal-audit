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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: l10n.websiteUrl),
              validator: (val) => (val == null || val.isEmpty) ? l10n.errorEnterUrl : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(_controller.text);
                }
              },
              child: Text(l10n.runAudit),
            ),
          ],
        ),
      ),
    );
  }
}
