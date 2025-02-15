import 'package:flutter/material.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/themes/theme.dart';

class TasksBadge extends StatelessWidget {
  TasksBadge({super.key, this.child});

  final JournalDb _db = getIt<JournalDb>();
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _db.watchInProgressTasksCount(),
      builder: (
        BuildContext context,
        AsyncSnapshot<int> snapshot,
      ) {
        final count = snapshot.data ?? 0;

        return Badge(
          label: Text('$count', style: badgeStyle),
          isLabelVisible: count != 0,
          backgroundColor: styleConfig().alarm,
          child: child,
        );
      },
    );
  }
}
