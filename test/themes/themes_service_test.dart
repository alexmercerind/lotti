import 'package:flutter_test/flutter_test.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/themes/themes.dart';
import 'package:lotti/themes/themes_service.dart';
import 'package:lotti/utils/color.dart';
import 'package:lotti/utils/consts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemesService test -', () {
    setUpAll(() {
      final db = JournalDb(inMemoryDatabase: true);

      getIt.registerSingleton<JournalDb>(db);

      db.insertFlagIfNotExists(
        const ConfigFlag(
          name: showBrightSchemeFlag,
          description: 'Show Bright ☀️ scheme?',
          status: false,
        ),
      );
    });
    tearDownAll(() async {
      await getIt.reset();
    });

    test('updated color by key appears in stream after theme toggle', () async {
      final themesService = ThemesService();

      expect(
        await themesService.watchColorByKey('negspace').first,
        darkTheme.negspace,
      );

      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);

      expect(
        await themesService.watchColorByKey('negspace').first,
        brightTheme.negspace,
      );
    });

    test('updated color config appears in stream after setting theme',
        () async {
      final themesService = ThemesService();

      await getIt<JournalDb>()
          .setConfigFlag(showBrightSchemeFlag, value: false);

      expect(
        await themesService.getStyleConfigStream().first,
        darkTheme,
      );

      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);

      expect(
        await themesService.getStyleConfigStream().first,
        brightTheme,
      );
    });

    test('color is updated after setting theme', () async {
      final themesService = ThemesService();

      await getIt<JournalDb>()
          .setConfigFlag(showBrightSchemeFlag, value: false);

      expect(
        await themesService.getStyleConfigStream().first,
        darkTheme,
      );

      expect(
        themesService.current.negspace,
        darkTheme.negspace,
      );

      themesService.setTheme(brightTheme);

      expect(
        themesService.current.negspace,
        brightTheme.negspace,
      );
    });

    test('color is updated with setColor', () async {
      final themesService = ThemesService();

      await getIt<JournalDb>()
          .setConfigFlag(showBrightSchemeFlag, value: false);

      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);
      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);

      expect(
        await themesService.watchColorByKey('negspace').first,
        darkTheme.negspace,
      );

      expect(
        themesService.current.negspace,
        darkTheme.negspace,
      );

      final testColor = colorFromCssHex('#FF0000');
      themesService.setColor('negspace', testColor);

      expect(
        themesService.current.negspace,
        testColor,
      );

      expect(
        await themesService.watchColorByKey('negspace').first,
        testColor,
      );
    });

    test('latest update DateTime is published on stream after setting theme',
        () async {
      final start = DateTime.now();
      await Future<void>.delayed(const Duration(milliseconds: 1));
      final themesService = ThemesService();

      await getIt<JournalDb>()
          .setConfigFlag(showBrightSchemeFlag, value: false);

      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);

      expect(
        (await themesService.getLastUpdateStream().first)
            .millisecondsSinceEpoch,
        greaterThan(start.millisecondsSinceEpoch),
      );

      await getIt<JournalDb>().toggleConfigFlag(showBrightSchemeFlag);

      expect(
        (await themesService.getLastUpdateStream().first)
            .millisecondsSinceEpoch,
        greaterThan(start.millisecondsSinceEpoch),
      );
    });
  });
}
