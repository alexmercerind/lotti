import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/classes/tag_type_definitions.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/logic/persistence_logic.dart';
import 'package:lotti/pages/empty_scaffold.dart';
import 'package:lotti/pages/settings/form_text_field.dart';
import 'package:lotti/services/tags_service.dart';
import 'package:lotti/themes/theme.dart';
import 'package:lotti/themes/utils.dart';
import 'package:lotti/widgets/app_bar/title_app_bar.dart';
import 'package:lotti/widgets/settings/form/form_switch.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TagEditPage extends StatefulWidget {
  const TagEditPage({
    required this.tagEntity,
    super.key,
  });

  final TagEntity tagEntity;

  @override
  State<TagEditPage> createState() {
    return _TagEditPageState();
  }
}

class _TagEditPageState extends State<TagEditPage> {
  final PersistenceLogic persistenceLogic = getIt<PersistenceLogic>();
  final _formKey = GlobalKey<FormBuilderState>();
  bool dirty = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    void maybePop() => Navigator.of(context).maybePop();

    Future<void> onSavePressed() async {
      _formKey.currentState!.save();
      if (_formKey.currentState!.validate()) {
        final formData = _formKey.currentState?.value;

        if (formData != null) {
          final private = formData['private'] as bool? ?? false;
          final inactive = formData['inactive'] as bool? ?? false;

          var newTagEntity = widget.tagEntity.copyWith(
            tag: '${formData['tag']}'.trim(),
            private: private,
            inactive: inactive,
            updatedAt: DateTime.now(),
          );

          final type = formData['type'] as String;

          if (type == 'PERSON') {
            newTagEntity = TagEntity.personTag(
              tag: newTagEntity.tag,
              vectorClock: newTagEntity.vectorClock,
              updatedAt: newTagEntity.updatedAt,
              createdAt: newTagEntity.createdAt,
              private: newTagEntity.private,
              inactive: newTagEntity.inactive,
              id: newTagEntity.id,
            );
          }

          if (type == 'STORY') {
            newTagEntity = TagEntity.storyTag(
              tag: newTagEntity.tag,
              vectorClock: newTagEntity.vectorClock,
              updatedAt: newTagEntity.updatedAt,
              createdAt: newTagEntity.createdAt,
              private: newTagEntity.private,
              inactive: newTagEntity.inactive,
              id: newTagEntity.id,
            );
          }

          if (type == 'TAG') {
            newTagEntity = TagEntity.genericTag(
              tag: newTagEntity.tag,
              vectorClock: newTagEntity.vectorClock,
              updatedAt: newTagEntity.updatedAt,
              createdAt: newTagEntity.createdAt,
              private: newTagEntity.private,
              inactive: newTagEntity.inactive,
              id: newTagEntity.id,
            );
          }

          await persistenceLogic.upsertTagEntity(newTagEntity);
          maybePop();

          setState(() {
            dirty = false;
          });
        }
      }
    }

    return Scaffold(
      appBar: TitleAppBar(
        title: widget.tagEntity.tag,
        actions: [
          if (dirty)
            TextButton(
              key: const Key('tag_save'),
              onPressed: onSavePressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  localizations.settingsTagsSaveLabel,
                  style: saveButtonStyle(),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: styleConfig().negspace,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                FormBuilder(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: () {
                    setState(() {
                      dirty = true;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      FormTextField(
                        initialValue: widget.tagEntity.tag,
                        labelText: localizations.settingsTagsTagName,
                        name: 'tag',
                        key: const Key('tag_name_field'),
                      ),
                      inputSpacer,
                      FormSwitch(
                        name: 'private',
                        initialValue: widget.tagEntity.private,
                        title: localizations.settingsTagsPrivateLabel,
                        activeColor: styleConfig().private,
                      ),
                      FormSwitch(
                        name: 'inactive',
                        initialValue: widget.tagEntity.inactive,
                        title: localizations.settingsTagsHideLabel,
                        activeColor: styleConfig().private,
                      ),
                      inputSpacer,
                      FormBuilderChoiceChip<String>(
                        name: 'type',
                        initialValue: widget.tagEntity.map(
                          genericTag: (_) => localizations.settingsTagsTypeTag,
                          personTag: (_) =>
                              localizations.settingsTagsTypePerson,
                          storyTag: (_) =>
                              localizations.settingsTagsTypeStory, // 'STORY',
                        ),
                        decoration: inputDecoration(
                          labelText: localizations.settingsTagsTypeLabel,
                        ),
                        selectedColor: widget.tagEntity.map(
                          genericTag: getTagColor,
                          personTag: getTagColor,
                          storyTag: getTagColor,
                        ),
                        runSpacing: 4,
                        spacing: 4,
                        options: [
                          FormBuilderChipOption<String>(
                            value: 'TAG',
                            child: Text(
                              localizations.settingsTagsTypeTag,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          FormBuilderChipOption<String>(
                            value: 'PERSON',
                            child: Text(
                              localizations.settingsTagsTypePerson,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          FormBuilderChipOption<String>(
                            value: 'STORY',
                            child: Text(
                              localizations.settingsTagsTypeStory,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(MdiIcons.trashCanOutline),
                        iconSize: 24,
                        tooltip: localizations.settingsTagsDeleteTooltip,
                        color: styleConfig().secondaryTextColor,
                        onPressed: () {
                          persistenceLogic.upsertTagEntity(
                            widget.tagEntity.copyWith(
                              deletedAt: DateTime.now(),
                            ),
                          );
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditExistingTagPage extends StatelessWidget {
  EditExistingTagPage({
    required this.tagEntityId,
    super.key,
  });

  final TagsService tagsService = getIt<TagsService>();
  final String tagEntityId;

  @override
  Widget build(BuildContext context) {
    final tagEntity = tagsService.getTagById(tagEntityId);

    if (tagEntity == null) {
      return const EmptyScaffoldWithTitle('');
    }

    return TagEditPage(tagEntity: tagEntity);
  }
}
