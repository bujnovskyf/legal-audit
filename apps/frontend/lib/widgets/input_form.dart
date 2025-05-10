// Purpose: Form to input website URL and submit.
import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Website URL'),
              validator: (val) => (val == null || val.isEmpty) ? 'Enter URL' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit(_controller.text);
                }
              },
              child: const Text('Run Audit'),
            ),
          ],
        ),
      ),
    );
  }
}