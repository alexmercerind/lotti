import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotti/blocs/journal/persistence_cubit.dart';
import 'package:lotti/blocs/journal/persistence_state.dart';
import 'package:lotti/classes/journal_entities.dart';
import 'package:lotti/theme.dart';
import 'package:lotti/widgets/journal/journal_card.dart';

class JournalPage2 extends StatefulWidget {
  const JournalPage2({
    Key? key,
    this.navigatorKey,
    required this.child,
  });

  final Widget child;
  final GlobalKey? navigatorKey;

  @override
  _JournalPage2State createState() => _JournalPage2State();
}

class _JournalPage2State extends State<JournalPage2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            return BlocBuilder<PersistenceCubit, PersistenceState>(
              builder: (BuildContext context, PersistenceState state) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppColors.headerBgColor,
                    title: widget.child,
                    centerTitle: true,
                  ),
                  backgroundColor: AppColors.bodyBgColor,
                  body: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                    child: state.when(
                      initial: () => const Text('initial'),
                      loading: () => const Text('loading'),
                      failed: () => const Text('failed'),
                      online: (List<JournalEntity> entries) {
                        debugPrint('entries.length ${entries.length}');
                        return ListView(
                          children: List.generate(
                            entries.length,
                            (int index) {
                              JournalEntity item = entries.elementAt(index);
                              return JournalCard(item: item, index: index);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
