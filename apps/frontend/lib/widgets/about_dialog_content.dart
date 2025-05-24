import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutDialogContent extends StatefulWidget {
  const AboutDialogContent({super.key});

  @override
  _AboutDialogContentState createState() => _AboutDialogContentState();
}

class _AboutDialogContentState extends State<AboutDialogContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _launchMail() async {
    final uri = Uri.parse('mailto:info@narrativva.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = screenWidth < 600;

    final double maxWidth = isMobile ? screenWidth * 0.95 : 900;

    final EdgeInsets padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 40, vertical: 32);

    final Color backgroundColor = isMobile ? Colors.white : Theme.of(context).cardColor;

    final double fontSize = isMobile ? 14 : 16;
    final double disclaimerFontSize = isMobile ? 11 : 13;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: isMobile ? 0 : 10,
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16)
          : const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenHeight * 0.85,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: backgroundColor,
            boxShadow: isMobile
                ? null
                : [
                    BoxShadow(
                      color: Color.fromARGB((0.08 * 255).round(), 0, 0, 0),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: fontSize,
                            color: const Color(0xFF18181B),
                          ),
                      children: [
                        TextSpan(text: l10n.aboutText),
                        TextSpan(
                          text: 'info@narrativva.com',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: fontSize,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _launchMail,
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  SelectableText(
                    l10n.disclaimerText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                          fontSize: disclaimerFontSize,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
