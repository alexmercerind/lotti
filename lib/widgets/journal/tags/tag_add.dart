import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/blocs/journal/entry_cubit.dart';
import 'package:lotti/blocs/journal/entry_state.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/services/tags_service.dart';
import 'package:lotti/widgets/journal/tags/tags_modal.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TagAddIconWidget extends StatelessWidget {
  TagAddIconWidget({super.key});

  final TagsService tagsService = getIt<TagsService>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<EntryCubit, EntryState>(
      builder: (
        context,
        EntryState state,
      ) {
        final item = state.entry;
        if (item == null) {
          return const SizedBox.shrink();
        }

        void onTapAdd() {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext _) {
              return BlocProvider.value(
                value: BlocProvider.of<EntryCubit>(context),
                child: const TagsModal(),
              );
            },
          );
        }

        return SizedBox(
          width: 40,
          child: IconButton(
            onPressed: onTapAdd,
            icon: const Icon(MdiIcons.tag),
            splashColor: Colors.transparent,
            tooltip: localizations.journalTagPlusHint,
          ),
        );
      },
    );
  }
}
