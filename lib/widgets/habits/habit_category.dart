import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/blocs/settings/habits/habit_settings_cubit.dart';
import 'package:lotti/blocs/settings/habits/habit_settings_state.dart';
import 'package:lotti/classes/entity_definitions.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/themes/theme.dart';
import 'package:lotti/utils/color.dart';
import 'package:lotti/widgets/settings/categories/categories_type_card.dart';
import 'package:lotti/widgets/settings/settings_card.dart';

class SelectCategoryWidget extends StatelessWidget {
  const SelectCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    return StreamBuilder<List<CategoryDefinition>>(
      stream: getIt<JournalDb>().watchCategories(),
      builder: (context, snapshot) {
        final categories = snapshot.data ?? <CategoryDefinition>[];
        final categoriesById = <String, CategoryDefinition>{};

        for (final category in categories) {
          categoriesById[category.id] = category;
        }

        return BlocBuilder<HabitSettingsCubit, HabitSettingsState>(
          builder: (
            context,
            HabitSettingsState state,
          ) {
            final habitDefinition = state.habitDefinition;
            final category = categoriesById[habitDefinition.categoryId];
            final cubit = context.read<HabitSettingsCubit>();

            controller.text = category?.name ?? '';

            void onTap() {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext _) {
                  return BlocProvider.value(
                    value: BlocProvider.of<HabitSettingsCubit>(context),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...categories.map(
                              (category) => SettingsCard(
                                onTap: () {
                                  context
                                      .read<HabitSettingsCubit>()
                                      .setCategory(category.id);
                                  Navigator.pop(context);
                                },
                                title: category.name,
                                leading: ColorIcon(
                                  colorFromCssHex(category.color),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            final categoryUndefined = state.habitDefinition.categoryId == null;
            final style =
                categoryUndefined ? searchFieldHintStyle() : searchFieldStyle();

            return TextField(
              onTap: onTap,
              readOnly: true,
              focusNode: FocusNode(),
              controller: controller,
              decoration: inputDecoration(
                labelText:
                    categoryUndefined ? '' : localizations.habitCategoryLabel,
                semanticsLabel: 'Select category',
              ).copyWith(
                icon: ColorIcon(
                  category != null
                      ? colorFromCssHex(category.color)
                      : styleConfig().secondaryTextColor.withOpacity(0.2),
                ),
                suffixIcon: categoryUndefined
                    ? null
                    : GestureDetector(
                        child: Icon(
                          Icons.close_rounded,
                          color: style.color,
                        ),
                        onTap: () {
                          controller.clear();
                          cubit.setCategory(null);
                        },
                      ),
                hintText: localizations.habitCategoryHint,
                hintStyle: style,
                border: InputBorder.none,
              ),
              style: style,
              //onChanged: widget.onChanged,
            );
          },
        );
      },
    );
  }
}
