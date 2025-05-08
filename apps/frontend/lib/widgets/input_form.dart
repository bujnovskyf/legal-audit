// A form widget to accept a URL from the user.
import 'package:flutter/material.dart';

class InputForm extends StatefulWidget {
  final void Function(String) onSubmit;
  const InputForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: _controller, decoration: const InputDecoration(labelText: 'Website URL')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onSubmit(_controller.text),
            child: const Text('Run Audit'),
          ),
        ],
      ),
    );
  }
}
