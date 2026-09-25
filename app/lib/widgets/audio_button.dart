import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/ui_text.dart';

class AudioButton extends StatelessWidget {
  /// Text to pronounce, in the course language.
  final String text;

  /// Course language: decides the audio asset key.
  final String lang;

  /// Interface language for the tooltip and the error message. Defaults to
  /// [lang] so existing call sites keep working, but a course word must not
  /// decide which language the user reads errors in.
  final String? uiLang;

  final bool compact;

  const AudioButton({
    super.key,
    required this.text,
    required this.lang,
    this.uiLang,
    this.compact = false,
  });

  Future<void> _play(BuildContext context) async {
    if (text.trim().isEmpty) return;
    final ok = await AudioService.instance.playText(text, lang);
    if (!ok && context.mounted) {
      final ui = uiLang ?? lang;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              uiText(
                ui,
                ar: 'الصوت غير متاح',
                pt: 'Áudio não disponível',
                other: 'Audio not available',
              ),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up),
      iconSize: compact ? 18 : 22,
      color: Theme.of(context).colorScheme.primary,
      tooltip: uiText(
        uiLang ?? lang,
        ar: 'استمع',
        pt: 'Ouvir',
        other: 'Listen',
      ),
      onPressed: () => _play(context),
    );
  }
}
