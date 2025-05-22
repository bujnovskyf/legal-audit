import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({super.key});

  void _launchMail() {
    launchUrl(Uri.parse('mailto:info@narrativva.com'));
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          const TextSpan(
            text:
                'Legal Audit je experimentální nástroj pro rychlý právní audit webových stránek.\n\n'
                'Co to dělá?\n'
                '• Najde a analyzuje důležité právní dokumenty (zásady ochrany osobních údajů, zásady cookies, obchodní podmínky) na zadané adrese.\n'
                '• Zhodnotí jejich dostupnost, strukturu a některé klíčové náležitosti.\n'
                '• Detekuje vybrané trackery a měřící nástroje.\n'
                '• Zobrazí, jaký výchozí souhlas (například s cookies) je na stránkách nastaven a co se ukládá ještě před interakcí uživatele.\n'
                '• Pomocí AI modelu (Grok) poskytuje i kvalitativní analýzu obsahu dokumentů.\n\n'
                'Jak to používat?\n'
                '1. Zadejte adresu webu, který chcete analyzovat.\n'
                '2. Spusťte audit a počkejte, než nástroj vyhledá dokumenty, analyzuje výchozí souhlas a detekuje trackery.\n'
                '3. Zkontrolujte a případně upravte nalezené dokumenty.\n'
                '4. Spusťte AI analýzu pro detailnější posouzení obsahu dokumentů.\n'
                '5. Projděte si výsledky a podívejte se na chybějící nebo nevyhovující části a detaily AI analýzy.\n\n'
                'Použité technologie: Flutter, Supabase, Vercel, Grok 3.\n\n'
                'Tento nástroj vznikl v rámci projektu Narrativva Labs.\n\n'
                'V případě jakýchkoliv dotazů nebo problémů nás kontaktujte na ',
          ),
          TextSpan(
            text: 'info@narrativva.com',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _launchMail,
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
