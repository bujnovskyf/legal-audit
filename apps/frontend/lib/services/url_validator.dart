class UrlValidator {
  static String? validate(String? val) {
    if (val == null || val.trim().isEmpty) return 'urlEmpty';
    String input = val.trim();
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }
    final uri = Uri.tryParse(input);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty ||
        !uri.host.contains('.')) {
      return 'urlInvalid';
    }
    return null;
  }

  static String normalize(String val) {
    String input = val.trim();
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://$input';
    }
    return input;
  }
}

