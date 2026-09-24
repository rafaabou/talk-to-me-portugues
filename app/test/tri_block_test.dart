import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_to_me_portugues/models/course_models.dart';
import 'package:talk_to_me_portugues/services/app_state.dart';
import 'package:talk_to_me_portugues/widgets/tri_block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(TriText text, AppState state) =>
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: TriBlock(text, contentLangOverride: 'pt'),
            ),
          ),
        ),
      );

  Future<AppState> makeState({
    String lang = 'en',
    bool showEnglish = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'ui_lang': lang,
      'ui_all_languages': showEnglish,
    });
    final state = AppState();
    await state.setLang(lang);
    await state.setShowEnglishTranslation(showEnglish);
    return state;
  }

  group('visibleTranslationLangs', () {
    test('arabic is always included', () {
      for (final showEnglish in [true, false]) {
        for (final uiLang in ['en', 'ar']) {
          expect(
            visibleTranslationLangs(
              contentLang: 'pt',
              uiLang: uiLang,
              showEnglish: showEnglish,
            ),
            contains('ar'),
            reason: 'ar missing for ui=$uiLang showEnglish=$showEnglish',
          );
        }
      }
    });

    test(
      'english shows for an english interface even when the switch is off',
      () {
        expect(
          visibleTranslationLangs(
            contentLang: 'pt',
            uiLang: 'en',
            showEnglish: false,
          ),
          ['en', 'ar'],
        );
      },
    );

    test('an arabic interface hides english until the switch is on', () {
      expect(
        visibleTranslationLangs(
          contentLang: 'pt',
          uiLang: 'ar',
          showEnglish: false,
        ),
        ['ar'],
      );
      expect(
        visibleTranslationLangs(
          contentLang: 'pt',
          uiLang: 'ar',
          showEnglish: true,
        ),
        ['en', 'ar'],
      );
    });

    test('a third interface language is added without duplicating', () {
      expect(
        visibleTranslationLangs(
          contentLang: 'es',
          uiLang: 'pt',
          showEnglish: false,
        ),
        ['pt', 'ar'],
      );
      expect(
        visibleTranslationLangs(
          contentLang: 'es',
          uiLang: 'es',
          showEnglish: false,
        ),
        ['ar'],
      );
    });
  });

  group('TriBlock language visibility', () {
    final tri = TriText('Bom dia', 'Good morning', 'صباح الخير');

    testWidgets('english interface shows the sentence, english and arabic', (
      tester,
    ) async {
      final state = await makeState(lang: 'en');
      await tester.pumpWidget(wrap(tri, state));

      expect(find.text('Bom dia'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('صباح الخير'), findsOneWidget);
    });

    testWidgets('arabic interface shows the sentence and arabic', (
      tester,
    ) async {
      final state = await makeState(lang: 'ar');
      await tester.pumpWidget(wrap(tri, state));

      expect(find.text('Bom dia'), findsOneWidget);
      expect(find.text('صباح الخير'), findsOneWidget);
      expect(find.text('Good morning'), findsNothing);
    });

    testWidgets('the english switch adds english to an arabic interface', (
      tester,
    ) async {
      final state = await makeState(lang: 'ar', showEnglish: true);
      await tester.pumpWidget(wrap(tri, state));

      expect(find.text('Bom dia'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('صباح الخير'), findsOneWidget);
    });

    testWidgets('never repeats the lesson line as its own translation', (
      tester,
    ) async {
      final noTranslation = TriText('Buenos días', '', '');
      final state = await makeState(lang: 'en');
      await tester.pumpWidget(wrap(noTranslation, state));
      expect(find.text('Buenos días'), findsOneWidget);
    });

    testWidgets('primary sentence is larger than the translation', (
      tester,
    ) async {
      final state = await makeState(lang: 'en');
      await tester.pumpWidget(wrap(tri, state));

      final primary = tester.widget<Text>(find.text('Bom dia'));
      final secondary = tester.widget<Text>(find.text('Good morning'));
      final primarySize =
          primary.style?.fontSize ??
          Theme.of(
            tester.element(find.text('Bom dia')),
          ).textTheme.titleMedium?.fontSize;
      final secondarySize =
          secondary.style?.fontSize ??
          Theme.of(
            tester.element(find.text('Good morning')),
          ).textTheme.bodyMedium?.fontSize;
      expect(primarySize, greaterThan(secondarySize!));
    });
  });
}
