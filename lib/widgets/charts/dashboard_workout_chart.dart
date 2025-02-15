import 'dart:core';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotti/blocs/charts/workout_chart_info_cubit.dart';
import 'package:lotti/classes/entity_definitions.dart';
import 'package:lotti/classes/journal_entities.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/logic/health_import.dart';
import 'package:lotti/themes/theme.dart';
import 'package:lotti/utils/wait.dart';
import 'package:lotti/widgets/charts/dashboard_chart.dart';
import 'package:lotti/widgets/charts/dashboard_workout_data.dart';
import 'package:lotti/widgets/charts/utils.dart';

class DashboardWorkoutChart extends StatefulWidget {
  const DashboardWorkoutChart({
    required this.chartConfig,
    required this.rangeStart,
    required this.rangeEnd,
    super.key,
  });

  final DashboardWorkoutItem chartConfig;
  final DateTime rangeStart;
  final DateTime rangeEnd;

  @override
  State<DashboardWorkoutChart> createState() => _DashboardWorkoutChartState();
}

class _DashboardWorkoutChartState extends State<DashboardWorkoutChart> {
  final JournalDb _db = getIt<JournalDb>();
  final HealthImport _healthImport = getIt<HealthImport>();
  final _chartState = charts.UserManagedState<DateTime>();

  @override
  void initState() {
    super.initState();

    runSoon(
      minWait: 1000,
      maxWait: 3000,
      callback: _healthImport.getWorkoutsHealthDataDelta,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkoutChartInfoCubit>(
      create: (BuildContext context) => WorkoutChartInfoCubit(),
      child: StreamBuilder<List<JournalEntity>>(
        stream: _db.watchWorkouts(
          rangeStart: widget.rangeStart,
          rangeEnd: widget.rangeEnd,
        ),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<JournalEntity>> snapshot,
        ) {
          final items = snapshot.data ?? [];

          void infoSelectionModelUpdated(
            charts.SelectionModel<DateTime> model,
          ) {
            if (model.hasDatumSelection) {
              final newSelection =
                  model.selectedDatum.first.datum as Observation;
              context.read<WorkoutChartInfoCubit>().setSelected(newSelection);

              _chartState.selectionModels[charts.SelectionModelType.info] =
                  charts.UserManagedSelectionModel(model: model);
            } else {
              context.read<WorkoutChartInfoCubit>().clearSelected();
              _chartState.selectionModels[charts.SelectionModelType.info] =
                  charts.UserManagedSelectionModel();
            }
          }

          final seriesList = <charts.Series<Observation, DateTime>>[
            charts.Series<Observation, DateTime>(
              id: widget.chartConfig.workoutType,
              domainFn: (Observation val, _) => val.dateTime,
              measureFn: (Observation val, _) => val.value,
              colorFn: (_, __) => charts.Color.fromHex(code: '#82E6CE'),
              data: aggregateWorkoutDailySum(
                items,
                chartConfig: widget.chartConfig,
                rangeStart: widget.rangeStart,
                rangeEnd: widget.rangeEnd,
              ),
            )
          ];

          return DashboardChart(
            chart: charts.TimeSeriesChart(
              seriesList,
              animate: false,
              behaviors: [
                chartRangeAnnotation(
                  widget.rangeStart,
                  widget.rangeEnd,
                ),
              ],
              domainAxis: timeSeriesAxis,
              defaultRenderer: defaultBarRenderer,
              selectionModels: [
                charts.SelectionModelConfig(
                  updatedListener: infoSelectionModelUpdated,
                ),
              ],
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec: const charts.BasicNumericTickProviderSpec(
                  zeroBound: false,
                  desiredTickCount: 5,
                  dataIsInWholeNumbers: true,
                ),
                renderSpec: numericRenderSpec,
              ),
            ),
            chartHeader: WorkoutChartInfoWidget(widget.chartConfig),
            height: 120,
          );
        },
      ),
    );
  }
}

class WorkoutChartInfoWidget extends StatelessWidget {
  const WorkoutChartInfoWidget(
    this.chartConfig, {
    super.key,
  });

  final DashboardWorkoutItem chartConfig;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutChartInfoCubit, WorkoutChartInfoState>(
      builder: (BuildContext context, WorkoutChartInfoState state) {
        final selected = state.selected;

        return Positioned(
          top: 0,
          left: 10,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: IgnorePointer(
              child: Row(
                children: [
                  Text(
                    chartConfig.displayName,
                    style: chartTitleStyle(),
                  ),
                  if (selected != null) ...[
                    const Spacer(),
                    Padding(
                      padding: AppTheme.chartDateHorizontalPadding,
                      child: Text(
                        ' ${ymd(selected.dateTime)}',
                        style: chartTitleStyle(),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      ' ${formatDailyAggregate(chartConfig, selected)}',
                      style: chartTitleStyle().copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
