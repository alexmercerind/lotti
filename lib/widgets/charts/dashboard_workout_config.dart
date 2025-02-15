import 'dart:core';

import 'package:lotti/classes/entity_definitions.dart';

Map<String, DashboardWorkoutItem> workoutTypes = {
  'walking.duration': DashboardWorkoutItem(
    displayName: 'Walking (time)',
    workoutType: 'walking',
    color: '#82E6CE',
    valueType: WorkoutValueType.duration,
  ),
  'walking.energy': DashboardWorkoutItem(
    displayName: 'Walking (calories)',
    workoutType: 'walking',
    color: '#82E6CE',
    valueType: WorkoutValueType.energy,
  ),
  'walking.distance': DashboardWorkoutItem(
    displayName: 'Walking distance (m)',
    workoutType: 'walking',
    color: '#82E6CE',
    valueType: WorkoutValueType.distance,
  ),
  'running.duration': DashboardWorkoutItem(
    displayName: 'Running (time)',
    workoutType: 'running',
    color: '#82E6CE',
    valueType: WorkoutValueType.duration,
  ),
  'running.energy': DashboardWorkoutItem(
    displayName: 'Running (calories)',
    workoutType: 'running',
    color: '#82E6CE',
    valueType: WorkoutValueType.energy,
  ),
  'running.distance': DashboardWorkoutItem(
    displayName: 'Running distance (m)',
    workoutType: 'running',
    color: '#82E6CE',
    valueType: WorkoutValueType.distance,
  ),
  'swimming.duration': DashboardWorkoutItem(
    displayName: 'Swimming (time)',
    workoutType: 'swimming',
    color: '#82E6CE',
    valueType: WorkoutValueType.duration,
  ),
  'swimming.energy': DashboardWorkoutItem(
    displayName: 'Swimming (calories)',
    workoutType: 'swimming',
    color: '#82E6CE',
    valueType: WorkoutValueType.energy,
  ),
  'swimming.distance': DashboardWorkoutItem(
    displayName: 'Swimming distance (m)',
    workoutType: 'swimming',
    color: '#82E6CE',
    valueType: WorkoutValueType.distance,
  ),
  'functionalStrengthTraining.duration': DashboardWorkoutItem(
    displayName: 'Strength training (time)',
    workoutType: 'functionalStrengthTraining',
    color: '#82E6CE',
    valueType: WorkoutValueType.duration,
  ),
  'functionalStrengthTraining.energy': DashboardWorkoutItem(
    displayName: 'Strength training (calories)',
    workoutType: 'functionalStrengthTraining',
    color: '#82E6CE',
    valueType: WorkoutValueType.energy,
  ),
};
