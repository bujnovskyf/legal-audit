// Home page: input form and submit button.
import 'package:flutter/material.dart';
import '../widgets/input_form.dart';
import 'result_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _navigateToResult(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultPage(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Legal Audit')),
      body: InputForm(onSubmit: (url) => _navigateToResult(context, url)),
    );
  }
}
