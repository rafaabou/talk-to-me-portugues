import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_to_me_portugues/models/course_models.dart';
import 'package:talk_to_me_portugues/screens/lesson_exercise_tile.dart';
import 'package:talk_to_me_portugues/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The real A1-02 drill the report came from: "Qual palavra significa
  // 'I am'?" The answer is the Portuguese `eu sou`, so the options have to
  // lead with the course language.
  final exercise = Exercise.fromJson({
    'type': 'multiple_choice',
    'prompt': {
      'pt': "Qual palavra significa 'I am'?",
      'en': "Which word means 'I am'?",
      'ar': "أي كلمة تعني 'أنا'؟",
    },
    'options': [
      {'pt': 'eu sou', 'en': 'I am', 'ar': 'أنا'},
      {'pt': 'bom dia', 'en': 'good morning', 'ar': 'صباح الخير'},
      {'pt': 'como vai?', 'en': 'how are you?', 'ar': 'كيف حالك؟'},
    ],
    'answer': 'eu sou',
    'explanation': {
      'pt': "'eu sou' significa 'I am'.",
      'en': "'eu sou' means 'I am'.",
      'ar': "تعني 'eu sou' 'أنا'.",
    },
  });

  Future<void> pumpOption(WidgetTester tester, String uiLang) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'ui_lang': uiLang});
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseTile(
              'A1-02',
              0,
              exercise,
              uiLang,
              isDone: false,
              onToggleDone: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('an English interface shows the Portuguese word, once', (
    tester,
  ) async {
    await pumpOption(tester, 'en');

    // The word being tested, plus each translation exactly once. The old code
    // used `o.tr(lang)`, so an English interface printed "I am" as the primary
    // and again on the English line, and never showed "eu sou" at all.
    expect(find.text('eu sou'), findsOneWidget);
    expect(find.text('I am'), findsOneWidget);
    expect(find.text('أنا'), findsOneWidget);
    expect(find.text('bom dia'), findsOneWidget);
    expect(find.text('good morning'), findsOneWidget);
    expect(find.text('صباح الخير'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an Arabic interface still leads with the Portuguese word', (
    tester,
  ) async {
    await pumpOption(tester, 'ar');

    expect(find.text('eu sou'), findsOneWidget);
    expect(find.text('I am'), findsOneWidget);
    expect(find.text('أنا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Portuguese interface does not repeat the word', (
    tester,
  ) async {
    await pumpOption(tester, 'pt');

    expect(find.text('eu sou'), findsOneWidget);
    expect(find.text('I am'), findsOneWidget);
    expect(find.text('أنا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an option identical in every language is shown once', (
    tester,
  ) async {
    // Hundreds of the options in the course data repeat the same text in all
    // three languages, e.g. {'pt': '24', 'en': '24', 'ar': '24'}.
    final same = Exercise.fromJson({
      'type': 'multiple_choice',
      'prompt': {'pt': 'Quantas letras?', 'en': 'How many letters?', 'ar': ''},
      'options': [
        {'pt': '24', 'en': '24', 'ar': '24'},
      ],
      'answer': '24',
      'explanation': {'pt': '', 'en': '', 'ar': ''},
    });

    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'ui_lang': 'en'});
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: MaterialApp(
          home: Scaffold(
            body: ExerciseTile(
              'A1-01',
              0,
              same,
              'en',
              isDone: false,
              onToggleDone: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('24'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
