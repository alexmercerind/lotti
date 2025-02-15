import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lotti/blocs/sync/sync_config_cubit.dart';
import 'package:lotti/database/logging_db.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/services/sync_config_service.dart';
import 'package:lotti/sync/inbox/inbox_service.dart';
import 'package:lotti/sync/outbox/outbox_service.dart';
import 'package:lotti/themes/theme.dart';
import 'package:lotti/themes/themes_service.dart';
import 'package:lotti/widgets/sync/imap_config_mobile.dart';
import 'package:lotti/widgets/sync/qr_reader_widget.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/sync_config_test_mocks.dart';
import '../../test_data/sync_config_test_data.dart';
import '../../widget_test_utils.dart';

void main() {
  var mock = MockSyncConfigService();
  var mockInboxService = MockSyncInboxService();
  var mockOutboxService = MockOutboxService();
  final mockLoggingDb = MockLoggingDb();

  group('SyncConfig Mobile Widgets Tests - ', () {
    setUp(() {
      mockInboxService = MockSyncInboxService();
      mockOutboxService = MockOutboxService();

      when(mockInboxService.init).thenAnswer((_) async {});
      when(mockOutboxService.init).thenAnswer((_) async {});

      getIt
        ..registerSingleton<OutboxService>(mockOutboxService)
        ..registerSingleton<InboxService>(mockInboxService)
        ..registerSingleton<LoggingDb>(mockLoggingDb)
        ..registerSingleton<ThemesService>(ThemesService(watch: false));
    });
    tearDown(getIt.reset);

    testWidgets(
        'Widget shows server information when configured, with connection success',
        (tester) async {
      mock = MockSyncConfigService();
      when(mock.getSharedKey).thenAnswer((_) async => testSharedKey);
      when(mock.getImapConfig).thenAnswer((_) async => testImapConfig);

      when(() => mock.testConnection(testSyncConfigConfigured))
          .thenAnswer((_) async => true);

      getIt.registerSingleton<SyncConfigService>(mock);

      await tester.pumpWidget(
        BlocProvider<SyncConfigCubit>(
          lazy: false,
          create: (BuildContext context) => SyncConfigCubit(
            testOnNetworkChange: true,
          ),
          child: makeTestableWidget(const MobileSyncConfig()),
        ),
      );

      await tester.pumpAndSettle();

      final hostFinder = find.text('Host: ${testImapConfig.host}');
      final portFinder = find.text('Port: ${testImapConfig.port}');
      final folderFinder = find.text('IMAP Folder: ${testImapConfig.folder}');
      final userFinder = find.text('User: ${testImapConfig.userName}');

      expect(hostFinder, findsOneWidget);
      expect(portFinder, findsOneWidget);
      expect(folderFinder, findsOneWidget);
      expect(userFinder, findsOneWidget);

      final successIndicatorFinder =
          find.byContainerColor(color: styleConfig().primaryColor);
      expect(successIndicatorFinder, findsOneWidget);
    });

    testWidgets('Widget shows QR scanner when not configured', (tester) async {
      mock = MockSyncConfigService();
      when(mock.getSharedKey).thenAnswer((_) async => null);
      when(mock.getImapConfig).thenAnswer((_) async => null);

      getIt.registerSingleton<SyncConfigService>(mock);

      await tester.pumpWidget(
        BlocProvider<SyncConfigCubit>(
          lazy: false,
          create: (BuildContext context) => SyncConfigCubit(
            testOnNetworkChange: true,
          ),
          child: makeTestableWidget(const MobileSyncConfig()),
        ),
      );

      await tester.pumpAndSettle();
      final scannerLabelFinder = find.text('Scanning Shared Secret...');
      expect(scannerLabelFinder, findsOneWidget);
    });

    testWidgets(
        'Widget shows server information when configured, with connection fail,'
        ' then camera after tapping delete button.', (tester) async {
      mock = MockSyncConfigService();
      when(mock.getSharedKey).thenAnswer((_) async => testSharedKey);
      when(mock.getImapConfig).thenAnswer((_) async => testImapConfig);

      when(() => mock.testConnection(testSyncConfigConfigured))
          .thenAnswer((_) async => false);

      getIt.registerSingleton<SyncConfigService>(mock);

      when(mock.deleteSharedKey).thenAnswer((_) async {
        when(mock.getSharedKey).thenAnswer((_) async => null);
      });

      when(mock.deleteImapConfig).thenAnswer((_) async {
        when(mock.getImapConfig).thenAnswer((_) async => null);
      });

      await tester.pumpWidget(
        BlocProvider<SyncConfigCubit>(
          lazy: false,
          create: (BuildContext context) => SyncConfigCubit(
            testOnNetworkChange: true,
          ),
          child: makeTestableWidget(const MobileSyncConfig()),
        ),
      );

      await tester.pumpAndSettle();

      final hostFinder = find.text('Host: ${testImapConfig.host}');
      final portFinder = find.text('Port: ${testImapConfig.port}');
      final folderFinder = find.text('IMAP Folder: ${testImapConfig.folder}');
      final userFinder = find.text('User: ${testImapConfig.userName}');

      expect(hostFinder, findsOneWidget);
      expect(portFinder, findsOneWidget);
      expect(folderFinder, findsOneWidget);
      expect(userFinder, findsOneWidget);

      final successIndicatorFinder =
          find.byContainerColor(color: styleConfig().alarm);

      final deleteButtonFinder = find.text('Delete Sync Configuration');
      final scannerLabelFinder = find.text('Scanning Shared Secret...');

      expect(successIndicatorFinder, findsOneWidget);

      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();

      expect(scannerLabelFinder, findsOneWidget);
    });

    testWidgets(
        'QR reader widget shows delete button when state is something '
        'other than empty.', (tester) async {
      mock = MockSyncConfigService();
      when(mock.getSharedKey).thenAnswer((_) async => testSharedKey);
      when(mock.getImapConfig).thenAnswer((_) async => testImapConfig);

      when(() => mock.testConnection(testSyncConfigConfigured))
          .thenAnswer((_) async => false);

      getIt.registerSingleton<SyncConfigService>(mock);

      when(mock.deleteSharedKey).thenAnswer((_) async {
        when(mock.getSharedKey).thenAnswer((_) async => null);
      });

      when(mock.deleteImapConfig).thenAnswer((_) async {
        when(mock.getImapConfig).thenAnswer((_) async => null);
      });

      await tester.pumpWidget(
        BlocProvider<SyncConfigCubit>(
          lazy: false,
          create: (BuildContext context) => SyncConfigCubit(
            testOnNetworkChange: true,
          ),
          child: makeTestableWidget(const EncryptionQrReaderWidget()),
        ),
      );

      await tester.pumpAndSettle();

      final deleteButtonFinder = find.text('Delete Sync Configuration');
      expect(deleteButtonFinder, findsOneWidget);

      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();

      final scannerLabelFinder = find.text('Scanning Shared Secret...');
      expect(scannerLabelFinder, findsOneWidget);

      expect(deleteButtonFinder, findsNothing);
    });
  });
}
