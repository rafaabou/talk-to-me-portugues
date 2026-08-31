import 'package:flutter_test/flutter_test.dart';
import 'package:talk_to_me_portugues/models/course_models.dart';
import 'package:talk_to_me_portugues/models/verb_models.dart';

void main() {
  test('parses augmented lesson (writing/listening/fill_blank/speaking)', () {
    final lesson = Lesson.fromJson({
      'id': 'A1-06',
      'level': 'A1',
      'title': {'pt': 'a', 'en': 'a', 'ar': 'a'},
      'objectives': [],
      'vocabulary': [
        {'pt': 'falar', 'ipa': '', 'en': 'to speak', 'ar': 'يتكلم'},
      ],
      'grammar': [],
      'dialogue': {
        'title': {'pt': 't', 'en': 't', 'ar': 't'},
        'lines': [
          {'speaker': 'A', 'pt': 'Olá.', 'en': 'Hi.', 'ar': 'مرحبا'},
        ],
      },
      'reading': null,
      'speaking': {
        'title': {'pt': 'Fale', 'en': 'Speak', 'ar': 'تحدث'},
        'phrases': [
          {'pt': 'Olá.', 'en': 'Hi.', 'ar': 'مرحبا'},
        ],
      },
      'exercises': [
        {
          'type': 'writing',
          'prompt': {'pt': 'p', 'en': 'p', 'ar': 'p'},
          'options': [],
          'answer': 'falar',
          'accepted': ['fala'],
          'explanation': {'pt': 'x', 'en': 'x', 'ar': 'x'},
        },
        {
          'type': 'listening',
          'prompt': {'pt': 'p', 'en': 'p', 'ar': 'p'},
          'options': [
            {'pt': 'a', 'en': 'a', 'ar': 'a'},
            {'pt': 'b', 'en': 'b', 'ar': 'b'},
          ],
          'answer': 'a',
          'accepted': [],
          'audio': 'Olá.',
          'explanation': {'pt': 'x', 'en': 'x', 'ar': 'x'},
        },
      ],
    });

    expect(lesson.speaking, hasLength(1));
    expect(lesson.speaking.first.text.pt, 'Olá.');

    final writing = lesson.exercises.firstWhere((e) => e.type == 'writing');
    expect(writing.accepted, ['fala']);
    expect(writing.answer, 'falar');

    final listening = lesson.exercises.firstWhere((e) => e.type == 'listening');
    expect(listening.audio, 'Olá.');
    expect(listening.options, hasLength(2));
  });

  test('trivial sanity test', () {
    expect(1 + 1, 2);
  });

  test('parses vocab example sentence', () {
    final lesson = Lesson.fromJson({
      'id': 'A1-01',
      'level': 'A1',
      'title': {'pt': 'a', 'en': 'a', 'ar': 'a'},
      'objectives': [],
      'vocabulary': [
        {
          'pt': 'falar',
          'ipa': '/faˈlaɾ/',
          'en': 'to speak',
          'ar': 'يتكلم',
          'example': {
            'pt': 'Eu falo português.',
            'en': 'I speak Portuguese.',
            'ar': 'أتحدث البرتغالية.',
          },
        },
      ],
      'grammar': [],
      'dialogue': {
        'title': {'pt': 't', 'en': 't', 'ar': 't'},
        'lines': [],
      },
      'reading': null,
      'speaking': {
        'title': {'pt': 't', 'en': 't', 'ar': 't'},
        'phrases': [],
      },
      'exercises': [],
    });
    final v = lesson.vocabulary.first;
    expect(v.example, isNotNull);
    expect(v.example!.pt, 'Eu falo português.');
    expect(v.example!.en, 'I speak Portuguese.');
  });

  test('parses dictation exercise', () {
    final e = Exercise.fromJson({
      'type': 'dictation',
      'prompt': {
        'pt': 'Ouça e escreva.',
        'en': 'Listen and type.',
        'ar': 'استمع واكتب.',
      },
      'options': [],
      'answer': 'Olá, tudo bem?',
      'accepted': [],
      'audio': 'Olá, tudo bem?',
      'explanation': {'pt': 'x', 'en': 'x', 'ar': 'x'},
    });
    expect(e.type, 'dictation');
    expect(e.audio, 'Olá, tudo bem?');
  });

  test('verb model parses 6 tenses x 6 persons', () {
    final data = VerbData(
      [TenseInfo('present', TriTextLabel('Presente', 'Present', 'المضارع'))],
      ['eu', 'você', 'ele/ela', 'nós', 'vocês', 'eles/elas'],
      {'-ar': []},
      [
        VerbInfo('ser', 'to be', 'يكون', 'irregular', false, {
          'present': ['sou', 'é', 'é', 'somos', 'são', 'são'],
        }),
      ],
    );
    expect(data.verbs.first.conjugation('present'), hasLength(6));
    expect(data.verbs.first.conjugation('present').first, 'sou');
    expect(data.tenses.first.label.pt, 'Presente');
  });
}
