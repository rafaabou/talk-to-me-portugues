import 'package:flutter_test/flutter_test.dart';
import 'package:talk_to_me_portugues/models/course_models.dart';
import 'package:talk_to_me_portugues/services/exercise_dedup.dart';

Exercise _ex(
  String type,
  String prompt,
  String answer, [
  List<String> options = const [],
  String promptEn = 'prompt-en',
]) => Exercise(
  type,
  TriText(prompt, promptEn, 'prompt-ar'),
  options.map((o) => TriText(o, 'opt-en', 'opt-ar')).toList(),
  answer,
  const [],
  null,
  TriText('', '', ''),
);

void main() {
  group('normalizeForDedup', () {
    test('strips case, accents and punctuation', () {
      expect(normalizeForDedup('  Bom dia!  '), 'bom dia');
      expect(normalizeForDedup('¿Cómo estás?'), 'como estas');
      expect(normalizeForDedup('A, B, C...'), 'a b c');
      expect(normalizeForDedup('coração'), 'coracao');
    });
  });

  group('dedupeExercises', () {
    test('collapses an exact duplicate', () {
      final list = [
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
      ];
      final out = dedupeExercises(list, 'pt');
      expect(out, hasLength(1));
      expect(out.first.key, 0);
    });

    test('collapses a duplicate that differs only in formatting', () {
      final list = [
        _ex('translation', 'Traduza: Bom dia!', 'Good morning'),
        _ex('translation', 'traduza: bom dia', 'Good morning.'),
      ];
      expect(dedupeExercises(list, 'pt'), hasLength(1));
    });

    test('collapses the same MCQ question reworded', () {
      final list = [
        _ex('multiple_choice', 'Qual é a tradução?', 'Bom dia', [
          'Bom dia',
          'Boa noite',
        ]),
        _ex('multiple_choice', 'Escolha a opção correta:', 'Bom dia', [
          'Boa noite',
          'Bom dia',
        ]),
      ];
      expect(dedupeExercises(list, 'pt'), hasLength(1));
    });

    test('keeps an MCQ with the same answer but different options', () {
      final list = [
        _ex('multiple_choice', 'Qual é a tradução?', 'Bom dia', [
          'Bom dia',
          'Boa noite',
        ]),
        _ex('multiple_choice', 'Qual é a tradução?', 'Bom dia', [
          'Bom dia',
          'Até logo',
        ]),
      ];
      expect(dedupeExercises(list, 'pt'), hasLength(2));
    });

    test('keeps different exercise types on the same sentence', () {
      final list = [
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('sentence_reorder', 'Reordene: Bom dia', 'Bom dia'),
      ];
      expect(dedupeExercises(list, 'pt'), hasLength(2));
    });

    test('preserves the original indices for progress keys', () {
      final list = [
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('translation', 'Traduza: Boa noite', 'Good night'),
      ];
      final out = dedupeExercises(list, 'pt');
      expect(out.map((e) => e.key), [0, 2]);
      expect(out.last.value.answer, 'Good night');
    });

    test('dedupedExerciseCount matches the rendered list', () {
      final list = [
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('writing', 'Escreva: Boa noite', 'Good night'),
      ];
      expect(dedupedExerciseCount(list, 'pt'), 2);
    });
  });

  group('audioDrillOrdinals', () {
    List<MapEntry<int, Exercise>> visibleOf(List<Exercise> list) =>
        dedupeExercises(list, 'pt');

    test('numbers repeated listening_mcq drills', () {
      final visible = visibleOf([
        _ex('listening_mcq', 'Ouça e escolha:', 'Bom dia'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Boa noite'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Até logo'),
      ]);
      final map = audioDrillOrdinals(visible);
      expect(map[0], (1, 3));
      expect(map[1], (2, 3));
      expect(map[2], (3, 3));
    });

    test('counts each drill type separately', () {
      final visible = visibleOf([
        _ex('listening_mcq', 'Ouça e escolha:', 'Bom dia'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Boa noite'),
        _ex('listening', 'O que você ouviu?', 'Bom dia!'),
        _ex('listening', 'O que você ouviu?', 'Boa noite!'),
      ]);
      final map = audioDrillOrdinals(visible);
      expect(map[0], (1, 2));
      expect(map[1], (2, 2));
      expect(map[2], (1, 2));
      expect(map[3], (2, 2));
    });

    test('skips a type that has only one drill', () {
      final visible = visibleOf([
        _ex('listening_mcq', 'Ouça e escolha:', 'Bom dia'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Boa noite'),
        _ex('dictation', 'Escreva o que ouviu', 'Bom dia!'),
      ]);
      final map = audioDrillOrdinals(visible);
      expect(map.containsKey(2), isFalse);
      expect(map[0], (1, 2));
    });

    test('ignores non-audio exercise types', () {
      final visible = visibleOf([
        _ex('translation', 'Traduza: Bom dia', 'Good morning'),
        _ex('sentence_reorder', 'Reordene: Bom dia', 'Bom dia'),
      ]);
      expect(audioDrillOrdinals(visible), isEmpty);
    });

    test('numbers follow the de-duplicated list, not the raw indices', () {
      final visible = visibleOf([
        _ex('listening_mcq', 'Ouça e escolha:', 'Bom dia'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Bom dia'),
        _ex('listening_mcq', 'Ouça e escolha:', 'Boa noite'),
      ]);
      expect(visible.map((e) => e.key), [0, 2]);
      final map = audioDrillOrdinals(visible);
      expect(map[0], (1, 2));
      expect(map[2], (2, 2));
    });
  });
}
