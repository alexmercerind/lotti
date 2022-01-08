import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:lotti/blocs/journal/persistence_cubit.dart';
import 'package:lotti/classes/entry_text.dart';
import 'package:lotti/classes/geolocation.dart';
import 'package:lotti/classes/journal_entities.dart';
import 'package:lotti/theme.dart';
import 'package:lotti/widgets/audio/audio_player.dart';
import 'package:lotti/widgets/journal/editor_tools.dart';
import 'package:lotti/widgets/journal/editor_widget.dart';
import 'package:lotti/widgets/journal/entry_datetime_modal.dart';
import 'package:lotti/widgets/journal/entry_image_widget.dart';
import 'package:lotti/widgets/journal/entry_tools.dart';
import 'package:lotti/widgets/misc/map_widget.dart';
import 'package:lotti/widgets/misc/survey_summary.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';

class EntryDetailWidget extends StatefulWidget {
  final JournalEntity item;
  final bool readOnly;
  const EntryDetailWidget({
    Key? key,
    required this.item,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<EntryDetailWidget> createState() => _EntryDetailWidgetState();
}

class _EntryDetailWidgetState extends State<EntryDetailWidget> {
  Directory? docDir;
  bool mapVisible = false;
  double editorHeight = (Platform.isIOS || Platform.isAndroid) ? 280 : 400;
  double imageTextEditorHeight =
      (Platform.isIOS || Platform.isAndroid) ? 160 : 400;

  @override
  void initState() {
    super.initState();

    getApplicationDocumentsDirectory().then((value) {
      setState(() {
        docDir = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Geolocation? loc = widget.item.geolocation;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
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
                      item: widget.item,
                    );
                  },
                );
              },
              child: Text(
                df.format(widget.item.meta.dateFrom),
                style: textStyle,
              ),
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
              icon: const Icon(MdiIcons.trashCanOutline),
              iconSize: 24,
              tooltip: 'Delete',
              color: AppColors.appBarFgColor,
              onPressed: () {
                context
                    .read<PersistenceCubit>()
                    .deleteJournalEntity(widget.item);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        Visibility(
          visible: mapVisible,
          child: MapWidget(
            geolocation: widget.item.geolocation,
          ),
        ),
        widget.item.maybeMap(
          journalAudio: (JournalAudio audio) {
            QuillController _controller =
                makeController(serializedQuill: audio.entryText?.quill);

            void saveText() {
              EntryText entryText = entryTextFromController(_controller);

              context
                  .read<PersistenceCubit>()
                  .updateJournalEntityText(widget.item, entryText);
            }

            return Column(
              children: [
                const AudioPlayerWidget(),
                EditorWidget(
                  controller: _controller,
                  height: editorHeight,
                  saveFn: saveText,
                ),
              ],
            );
          },
          journalImage: (JournalImage image) {
            QuillController _controller =
                makeController(serializedQuill: image.entryText?.quill);

            void saveText() {
              EntryText entryText = entryTextFromController(_controller);

              context
                  .read<PersistenceCubit>()
                  .updateJournalEntityText(widget.item, entryText);
            }

            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: EntryImageWidget(
                    journalImage: image,
                    height: 400,
                  ),
                ),
                EditorWidget(
                  controller: _controller,
                  readOnly: widget.readOnly,
                  height: imageTextEditorHeight,
                  saveFn: saveText,
                ),
              ],
            );
          },
          journalEntry: (JournalEntry journalEntry) {
            QuillController _controller =
                makeController(serializedQuill: journalEntry.entryText.quill);

            void saveText() {
              context.read<PersistenceCubit>().updateJournalEntityText(
                  widget.item, entryTextFromController(_controller));
            }

            return EditorWidget(
              controller: _controller,
              readOnly: widget.readOnly,
              saveFn: saveText,
            );
          },
          measurement: (MeasurementEntry entry) {
            QuillController _controller =
                makeController(serializedQuill: entry.entryText?.quill);

            void saveText() {
              context.read<PersistenceCubit>().updateJournalEntityText(
                  widget.item, entryTextFromController(_controller));
            }

            return EditorWidget(
              controller: _controller,
              readOnly: widget.readOnly,
              saveFn: saveText,
            );
          },
          survey: (SurveyEntry surveyEntry) => SurveySummaryWidget(surveyEntry),
          quantitative: (qe) => qe.data.map(
            cumulativeQuantityData: (qd) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: InfoText(
                'End: ${df.format(qe.meta.dateTo)}'
                '\n${formatType(qd.dataType)}: '
                '${nf.format(qd.value)} ${formatUnit(qd.unit)}',
              ),
            ),
            discreteQuantityData: (qd) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: InfoText(
                'End: ${df.format(qe.meta.dateTo)}'
                '\n${formatType(qd.dataType)}: '
                '${nf.format(qd.value)} ${formatUnit(qd.unit)}',
              ),
            ),
          ),
          orElse: () => Container(),
        ),
      ],
    );
  }
}
