import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lotti/blocs/journal/persistence_cubit.dart';
import 'package:lotti/classes/geolocation.dart';
import 'package:lotti/classes/journal_entities.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/main.dart';
import 'package:lotti/theme.dart';
import 'package:lotti/utils/platform.dart';
import 'package:lotti/widgets/journal/entry_datetime_modal.dart';
import 'package:lotti/widgets/journal/entry_tools.dart';
import 'package:lotti/widgets/misc/map_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/src/provider.dart';

class EntryDetailFooter extends StatefulWidget {
  final JournalEntity item;
  const EntryDetailFooter({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<EntryDetailFooter> createState() => _EntryDetailFooterState();
}

class _EntryDetailFooterState extends State<EntryDetailFooter> {
  bool mapVisible = isDesktop;

  final JournalDb db = getIt<JournalDb>();
  late final Stream<JournalEntity?> stream =
      db.watchEntityById(widget.item.meta.id);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Geolocation? loc = widget.item.geolocation;

    return StreamBuilder<JournalEntity?>(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<JournalEntity?> snapshot,
        ) {
          JournalEntity? liveEntity = snapshot.data;
          if (liveEntity == null) {
            return const SizedBox.shrink();
          }

          return Container(
            color: AppColors.headerBgColor,
            child: Column(
              children: [
                Visibility(
                  visible: mapVisible,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    child: MapWidget(
                      geolocation: widget.item.geolocation,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return EntryDateTimeModal(
                              item: liveEntity,
                            );
                          },
                        );
                      },
                      child: Text(
                        df.format(liveEntity.meta.dateFrom),
                        style: textStyle,
                      ),
                    ),
                    Text(
                      entryDuration(liveEntity).toString().split('.').first,
                      style: textStyle,
                    ),
                    Visibility(
                      visible: loc != null && loc.longitude != 0,
                      child: TextButton(
                        onPressed: () => setState(() {
                          mapVisible = !mapVisible;
                        }),
                        child: Text(
                          '📍 ${formatLatLon(loc?.latitude)}, '
                          '${formatLatLon(loc?.longitude)}',
                          style: textStyle,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(mapVisible
                          ? MdiIcons.chevronDoubleDown
                          : MdiIcons.chevronDoubleUp),
                      iconSize: 24,
                      tooltip: 'Details',
                      color: AppColors.appBarFgColor,
                      onPressed: () {
                        setState(() {
                          mapVisible = !mapVisible;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class EntryInfoRow extends StatelessWidget {
  final String entityId;
  final JournalDb db = getIt<JournalDb>();

  late final Stream<JournalEntity?> stream = db.watchEntityById(entityId);

  EntryInfoRow({
    Key? key,
    required this.entityId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<JournalEntity?>(
        stream: stream,
        builder: (
          BuildContext context,
          AsyncSnapshot<JournalEntity?> snapshot,
        ) {
          JournalEntity? liveEntity = snapshot.data;
          if (liveEntity == null) {
            return const SizedBox.shrink();
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SwitchRow(
                label: 'Starred:',
                activeColor: AppColors.starredGold,
                onChanged: (bool value) {
                  Metadata newMeta = liveEntity.meta.copyWith(
                    starred: value,
                  );
                  context
                      .read<PersistenceCubit>()
                      .updateJournalEntity(liveEntity, newMeta);
                },
                value: liveEntity.meta.starred ?? false,
              ),
              SwitchRow(
                label: 'Private:',
                activeColor: AppColors.error,
                onChanged: (bool value) {
                  Metadata newMeta = liveEntity.meta.copyWith(
                    private: value,
                  );
                  context
                      .read<PersistenceCubit>()
                      .updateJournalEntity(liveEntity, newMeta);
                },
                value: liveEntity.meta.private ?? false,
              ),
              SwitchRow(
                label: 'Flag:',
                activeColor: AppColors.error,
                onChanged: (bool value) {
                  Metadata newMeta = liveEntity.meta.copyWith(
                    flag: value ? EntryFlag.import : EntryFlag.none,
                  );
                  context
                      .read<PersistenceCubit>()
                      .updateJournalEntity(liveEntity, newMeta);
                },
                value: liveEntity.meta.flag == EntryFlag.import,
              ),
              SwitchRow(
                label: 'Trash:',
                activeColor: AppColors.error,
                onChanged: (bool value) {
                  if (value) {
                    context
                        .read<PersistenceCubit>()
                        .deleteJournalEntity(liveEntity);
                    Navigator.pop(context);
                  }
                },
                value: liveEntity.meta.deletedAt != null,
              ),
            ],
          );
        });
  }
}

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.value,
    required this.activeColor,
  }) : super(key: key);

  final String label;
  final void Function(bool)? onChanged;
  final bool value;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: textStyle),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}
