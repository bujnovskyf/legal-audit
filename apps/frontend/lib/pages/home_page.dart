// Purpose: Display URL input form and navigate to results.
import 'package:flutter/material.dart';
import '../widgets/input_form.dart';
import 'result_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Audit')),
      body: InputForm(onSubmit: (url) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultPage(url: url)),
        );
      }),
    );
  }
}