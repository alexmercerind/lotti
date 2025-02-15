import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/classes/entity_definitions.dart';
import 'package:lotti/themes/theme.dart';

class DashboardItemModal extends StatelessWidget {
  const DashboardItemModal({
    required this.index,
    required this.item,
    required this.updateItemFn,
    required this.title,
    super.key,
  });

  final DashboardMeasurementItem item;
  final int index;
  final String title;
  final void Function(DashboardItem item, int index) updateItemFn;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ColoredBox(
      color: styleConfig().cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              style: titleStyle(),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.dashboardAggregationLabel,
              textAlign: TextAlign.end,
              style: labelStyleLarger().copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AggregationType.values.map((aggregationType) {
                return ChoiceChip(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onSelected: (_) {
                    updateItemFn(
                      item.copyWith(aggregationType: aggregationType),
                      index,
                    );
                    Navigator.pop(context);
                  },
                  label: Text(
                    EnumToString.convertToString(aggregationType),
                    style: choiceLabelStyle(),
                  ),
                  selectedColor: styleConfig().primaryColor,
                  selected: aggregationType == item.aggregationType,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
