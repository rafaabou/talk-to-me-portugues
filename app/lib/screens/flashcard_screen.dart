import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course_models.dart';
import '../services/app_state.dart';
import '../services/content_index.dart';
import '../services/fsrs.dart';
import '../services/progress_service.dart';
import '../widgets/audio_button.dart';
import '../widgets/app_selection_area.dart';
import '../widgets/credit_footer.dart';
import '../services/ui_text.dart';

class FlashcardScreen extends StatefulWidget {
  /// When true the session starts with the weakest due cards
  /// (lowest stability, most lapses) instead of an arbitrary shuffle.
  final bool weakestFirst;

  /// Maximum cards in a weak review session.
  final int limit;

  const FlashcardScreen({
    super.key,
    this.weakestFirst = false,
    this.limit = 20,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

/// One review card. Word, SRS key and example travel together in a single
/// object so a shuffle can never pair a word with another card's key.
class _Flashcard {
  final VocabWord word;
  final String key;
  final TriText? example;
  const _Flashcard(this.word, this.key, this.example);
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  List<_Flashcard>? _deck;
  int _index = 0;
  bool _revealed = false;
  int _known = 0;
  int _again = 0;
  bool _loading = true;
  bool _done = false;
  bool _dueOnly = false;
  int _repeatCount = 1;
  static const List<int> _repeatOptions = [1, 3, 7, 10];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final index = await ContentIndexRepository.instance.load();
    final due = await ProgressService.instance.getDueFsrsCards();
    final allKeys =
        (await ProgressService.instance.getFsrsCards()).keys.toSet();
    final repeatCount = await ProgressService.instance.getRepeatCount();
    // Ranked order matters for a weak review, so keep the list, not a set.
    final weakOrder =
        widget.weakestFirst && due.isNotEmpty
            ? weakestFirstCards(
              due,
              limit: widget.limit,
            ).map((c) => c.key).toList()
            : null;
    final weakRank = <String, int>{
      for (var i = 0; i < weakOrder!.length; i++) weakOrder[i]: i,
    };
    final cards = <_Flashcard>[];
    for (final v in index.vocab) {
      final key = v.key;
      if (weakRank.isNotEmpty && !weakRank.containsKey(key)) continue;
      final inSrs = allKeys.contains(key);
      final isDue = due.containsKey(key);
      final isUnseen = !inSrs;
      if (isDue || (!_dueOnly && isUnseen)) {
        cards.add(
          _Flashcard(
            VocabWord(v.text.pt, v.ipa, v.text.en, v.text.ar),
            key,
            v.example,
          ),
        );
      }
    }
    if (weakRank.isNotEmpty) {
      // Weakest first: the ranking from weakestFirstCards is the deck order.
      cards.sort((a, b) => weakRank[a.key]!.compareTo(weakRank[b.key]!));
    } else {
      cards.shuffle(Random());
    }
    if (!mounted) return;
    setState(() {
      _deck = cards;
      _dueOnly = due.isNotEmpty;
      _repeatCount = repeatCount;
      _loading = false;
    });
  }

  Future<void> _setRepeatCount(int count) async {
    await ProgressService.instance.setRepeatCount(count);
    if (!mounted) return;
    setState(() => _repeatCount = count);
  }

  Future<void> _next({required int rating}) async {
    final card = _deck![_index];
    // Awaited: both writes are read-modify-write on the same store, so
    // firing them unawaited loses updates when taps arrive quickly.
    await ProgressService.instance.markSrs(card.key, known: rating > 1);
    await ProgressService.instance.incrementFlashcardsReviewed(1);
    if (!mounted) return;
    setState(() {
      if (rating > 1) {
        _known++;
      } else {
        _again++;
        final repeats = _repeatCount.clamp(1, _repeatOptions.last);
        for (int i = 0; i < repeats; i++) {
          _deck!.add(card);
        }
      }
      _index++;
      if (_index >= _deck!.length) {
        _done = true;
      }
      _revealed = false;
    });
  }

  void _newSession() {
    setState(() {
      // The whole card moves together, so its SRS key stays correct.
      _deck!.shuffle(Random());
      _index = 0;
      _known = 0;
      _again = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().lang;

    if (_loading) {
      return AppSelectionArea(
        child: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final deck = _deck!;
    final done = _done || _index >= deck.length;

    return AppSelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            uiText(
              lang,
              ar: 'البطاقات التعليمية',
              pt: 'Tarjetas de Estudio',
              other: 'Flashcards',
            ),
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.replay),
              tooltip: 'Repeat count',
              onSelected: _setRepeatCount,
              itemBuilder:
                  (_) =>
                      _repeatOptions
                          .map(
                            (c) => PopupMenuItem(
                              value: c,
                              child: Text(_repeatCount == c ? '×$c ✓' : '×$c'),
                            ),
                          )
                          .toList(),
            ),
          ],
        ),
        body:
            done
                ? _buildResult(lang)
                : _buildCard(
                  deck[_index].word,
                  lang,
                  deck.length,
                  deck[_index].example,
                ),
      ),
    );
  }

  Widget _buildResult(String lang) {
    final total = _known + _again;
    final pct = total == 0 ? 0 : (_known * 100 / total).round();
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    uiText(
                      lang,
                      ar: 'انتهت الجلسة!',
                      pt: 'Sessão concluída!',
                      other: 'Session complete!',
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    uiText(
                      lang,
                      ar: 'عرفت $pct٪',
                      pt: 'Você acertou $pct%',
                      other: 'You knew $pct%',
                    ),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uiText(
                      lang,
                      ar: 'معروف: $_known · كرر لاحقًا: $_again',
                      pt: 'Acertos: $_known · Revisar depois: $_again',
                      other: 'Known: $_known · Review again: $_again',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _newSession,
                    child: Text(
                      uiText(
                        lang,
                        ar: 'جلسة جديدة',
                        pt: 'Nova sessão',
                        other: 'New session',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const CreditFooter(),
      ],
    );
  }

  Widget _buildCard(VocabWord word, String lang, int total, TriText? example) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_index + 1}/$total',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                uiText(
                  lang,
                  ar: 'أصايب: $_known · أخطاء: $_again',
                  pt: 'Acertos: $_known · Erros: $_again',
                  other: 'Known: $_known · Errors: $_again',
                ),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _revealed = !_revealed),
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.pt,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        word.ipa,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      AudioButton(text: word.pt, lang: 'pt'),
                      const SizedBox(height: 16),
                      if (_revealed) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          word.tr(lang),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        if (word.ar.isNotEmpty && word.ar != word.tr(lang))
                          Text(
                            word.ar,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        if (example != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            example.pt,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          if (example.en.isNotEmpty)
                            Text(
                              example.en,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (example.ar.isNotEmpty)
                            Text(
                              example.ar,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ] else
                        Text(
                          uiText(
                            lang,
                            ar: 'اضغط للكشف عن المعنى',
                            pt: 'Toque para revelar',
                            other: 'Tap to reveal',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_revealed)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children:
                      _repeatOptions.map((c) {
                        final isSelected = _repeatCount == c;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                        : null,
                              ),
                              onPressed: () => _setRepeatCount(c),
                              child: Text('×$c'),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _next(rating: 1),
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        label: Text(
                          uiText(
                            lang,
                            ar: 'مرة أخرى',
                            pt: 'De novo',
                            other: 'Again',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _next(rating: 3),
                        icon: const Icon(Icons.check),
                        label: Text(
                          uiText(
                            lang,
                            ar: 'أعرفها',
                            pt: 'Sei',
                            other: 'I know it',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => _next(rating: 4),
                        icon: const Icon(Icons.flash_on),
                        label: Text(
                          uiText(lang, ar: 'سهل', pt: 'Fácil', other: 'Easy'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const CreditFooter(),
      ],
    );
  }
}
