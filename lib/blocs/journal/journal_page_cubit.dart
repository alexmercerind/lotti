import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:lotti/blocs/journal/journal_page_state.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/database/fts5_db.dart';
import 'package:lotti/get_it.dart';

class JournalPageCubit extends Cubit<JournalPageState> {
  JournalPageCubit()
      : super(
          JournalPageState(
            match: '',
            tagIds: <String>{},
            starredEntriesOnly: false,
            flaggedEntriesOnly: false,
            privateEntriesOnly: false,
            showPrivateEntries: false,
            selectedEntryTypes: entryTypes,
            fullTextMatches: {},
            showTasks: false,
            pagingController: PagingController(firstPageKey: 0),
            taskStatuses: [
              'OPEN',
              'GROOMED',
              'IN PROGRESS',
              'BLOCKED',
              'ON HOLD',
              'DONE',
              'REJECTED',
            ],
            selectedTaskStatuses: {
              'OPEN',
              'GROOMED',
              'IN PROGRESS',
            },
          ),
        ) {
    getIt<JournalDb>().watchConfigFlag('private').listen((showPrivate) {
      _showPrivateEntries = showPrivate;
      emitState();
    });

    state.pagingController.addPageRequestListener(_fetchPage);

    hotKeyManager.register(
      HotKey(
        KeyCode.keyR,
        modifiers: [KeyModifier.meta],
        scope: HotKeyScope.inapp,
      ),
      keyDownHandler: (hotKey) => refreshQuery(),
    );
  }

  final JournalDb _db = getIt<JournalDb>();
  static const _pageSize = 50;
  Set<String> _selectedEntryTypes = entryTypes.toSet();

  String _query = '';
  bool _starredEntriesOnly = false;
  bool _flaggedEntriesOnly = false;
  bool _privateEntriesOnly = false;
  bool _showPrivateEntries = false;
  bool _showTasks = false;

  Set<String> _fullTextMatches = {};

  Set<String> _selectedTaskStatuses = {
    'OPEN',
    'GROOMED',
    'IN PROGRESS',
  };

  void emitState() {
    emit(
      JournalPageState(
        match: _query,
        tagIds: <String>{},
        starredEntriesOnly: _starredEntriesOnly,
        flaggedEntriesOnly: _flaggedEntriesOnly,
        privateEntriesOnly: _privateEntriesOnly,
        showPrivateEntries: _showPrivateEntries,
        showTasks: _showTasks,
        selectedEntryTypes: _selectedEntryTypes.toList(),
        fullTextMatches: _fullTextMatches,
        pagingController: state.pagingController,
        taskStatuses: state.taskStatuses,
        selectedTaskStatuses: _selectedTaskStatuses,
      ),
    );
  }

  void setShowTasks({required bool showTasks}) {
    _showTasks = showTasks;
    refreshQuery();
  }

  void toggleStarredEntriesOnly() {
    _starredEntriesOnly = !_starredEntriesOnly;
    refreshQuery();
  }

  void toggleSelectedTaskStatus(String status) {
    if (_selectedTaskStatuses.contains(status)) {
      _selectedTaskStatuses =
          _selectedTaskStatuses.difference(<String>{status});
    } else {
      _selectedTaskStatuses = _selectedTaskStatuses.union({status});
    }

    refreshQuery();
  }

  void toggleSelectedEntryTypes(String entryType) {
    if (_selectedEntryTypes.contains(entryType)) {
      _selectedEntryTypes = _selectedEntryTypes.difference(<String>{entryType});
    } else {
      _selectedEntryTypes = _selectedEntryTypes.union({entryType});
    }

    refreshQuery();
  }

  void selectSingleEntryType(String entryType) {
    _selectedEntryTypes = {entryType};
    refreshQuery();
  }

  void selectAllEntryTypes() {
    _selectedEntryTypes = entryTypes.toSet();
    refreshQuery();
  }

  void clearSelectedEntryTypes() {
    _selectedEntryTypes = {};
    refreshQuery();
  }

  void selectSingleTaskStatus(String taskStatus) {
    _selectedTaskStatuses = {taskStatus};
    refreshQuery();
  }

  void selectAllTaskStatuses() {
    _selectedTaskStatuses = state.taskStatuses.toSet();
    refreshQuery();
  }

  void clearSelectedTaskStatuses() {
    _selectedTaskStatuses = {};
    refreshQuery();
  }

  void toggleFlaggedEntriesOnly() {
    _flaggedEntriesOnly = !_flaggedEntriesOnly;
    refreshQuery();
  }

  void togglePrivateEntriesOnly() {
    _privateEntriesOnly = !_privateEntriesOnly;
    refreshQuery();
  }

  Future<void> _fts5Search() async {
    if (_query.isEmpty) {
      _fullTextMatches = {};
    } else {
      final res = await getIt<Fts5Db>().watchFullTextMatches(_query).first;
      _fullTextMatches = res.toSet();
    }
  }

  Future<void> setSearchString(String query) async {
    _query = query;
    refreshQuery();
  }

  void refreshQuery() {
    emitState();
    state.pagingController.refresh();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final types = state.selectedEntryTypes.toList();

      await _fts5Search();

      final fullTextMatches = _fullTextMatches.toList();
      final ids = _query.isNotEmpty ? fullTextMatches : null;

      final newItems = _showTasks
          ? await _db
              .watchTasks(
                ids: ids,
                starredStatuses: _starredEntriesOnly ? [true] : [true, false],
                taskStatuses: _selectedTaskStatuses.toList(),
                limit: _pageSize,
                offset: pageKey,
              )
              .first
          : await _db
              .watchJournalEntities(
                types: types,
                ids: ids,
                starredStatuses: _starredEntriesOnly ? [true] : [true, false],
                privateStatuses: _privateEntriesOnly ? [true] : [true, false],
                flaggedStatuses: _flaggedEntriesOnly ? [1] : [1, 0],
                limit: _pageSize,
                offset: pageKey,
              )
              .first;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        state.pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        state.pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      state.pagingController.error = error;
    }
  }

  @override
  Future<void> close() async {
    state.pagingController.dispose();
    await super.close();
  }
}

final List<String> entryTypes = [
  'Task',
  'JournalEntry',
  'JournalAudio',
  'JournalImage',
  'MeasurementEntry',
  'SurveyEntry',
  'WorkoutEntry',
  'HabitCompletionEntry',
  'QuantitativeEntry',
];
