import 'package:beamer/beamer.dart';
import 'package:lotti/beamer/locations/dashboards_location.dart';
import 'package:lotti/beamer/locations/habits_location.dart';
import 'package:lotti/beamer/locations/journal_location.dart';
import 'package:lotti/beamer/locations/settings_location.dart';

final habitsBeamerDelegate = BeamerDelegate(
  initialPath: '/habits',
  updateParent: false,
  updateFromParent: false,
  locationBuilder: (routeInformation, _) {
    if (routeInformation.location!.contains('habits')) {
      return HabitsLocation(routeInformation);
    }
    return NotFound(path: routeInformation.location!);
  },
);

final dashboardsBeamerDelegate = BeamerDelegate(
  initialPath: '/dashboards',
  updateParent: false,
  updateFromParent: false,
  locationBuilder: (routeInformation, _) {
    if (routeInformation.location!.contains('dashboards')) {
      return DashboardsLocation(routeInformation);
    }
    return NotFound(path: routeInformation.location!);
  },
);

final journalBeamerDelegate = BeamerDelegate(
  initialPath: '/journal',
  updateParent: false,
  updateFromParent: false,
  locationBuilder: (routeInformation, _) {
    if (routeInformation.location!.contains('journal')) {
      return JournalLocation(routeInformation);
    }
    return NotFound(path: routeInformation.location!);
  },
);

final settingsBeamerDelegate = BeamerDelegate(
  initialPath: '/settings',
  updateParent: false,
  updateFromParent: false,
  locationBuilder: (routeInformation, _) {
    if (routeInformation.location!.contains('settings')) {
      return SettingsLocation(routeInformation);
    }
    return NotFound(path: routeInformation.location!);
  },
);
