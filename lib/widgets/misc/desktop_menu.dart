import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/database/database.dart';
import 'package:lotti/get_it.dart';
import 'package:lotti/logic/create/create_entry.dart';
import 'package:lotti/services/nav_service.dart';
import 'package:lotti/utils/consts.dart';

class DesktopMenuWrapper extends StatelessWidget {
  DesktopMenuWrapper({
    required this.child,
    super.key,
  });

  final JournalDb _db = getIt<JournalDb>();
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) {
      return child;
    }

    return MaterialApp(
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<Set<String>>(
        stream: _db.watchActiveConfigFlagNames(),
        builder: (context, snapshot) {
          final localizations = AppLocalizations.of(context)!;

          return PlatformMenuBar(
            menus: [
              const PlatformMenu(
                label: 'Lotti',
                menus: [
                  PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.about,
                  ),
                  PlatformMenuItemGroup(
                    members: [
                      PlatformProvidedMenuItem(
                        type: PlatformProvidedMenuItemType.servicesSubmenu,
                      ),
                    ],
                  ),
                  PlatformMenuItemGroup(
                    members: [
                      PlatformProvidedMenuItem(
                        type: PlatformProvidedMenuItemType.hide,
                      ),
                    ],
                  ),
                  PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.quit,
                  ),
                ],
              ),
              PlatformMenu(
                label: localizations.fileMenuTitle,
                menus: [
                  PlatformMenuItem(
                    label: localizations.fileMenuNewEntry,
                    onSelected: () async {
                      final linkedId = await getIdFromSavedRoute();
                      await createTextEntry(linkedId: linkedId);
                    },
                    shortcut: const SingleActivator(
                      LogicalKeyboardKey.keyN,
                      meta: true,
                    ),
                  ),
                  PlatformMenu(
                    label: localizations.fileMenuNewEllipsis,
                    menus: [
                      PlatformMenuItem(
                        label: localizations.fileMenuNewTask,
                        shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyT,
                          meta: true,
                        ),
                        onSelected: () async {
                          final linkedId = await getIdFromSavedRoute();
                          await createTask(linkedId: linkedId);
                        },
                      ),
                      PlatformMenuItem(
                        label: localizations.fileMenuNewScreenshot,
                        shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyS,
                          meta: true,
                          alt: true,
                        ),
                        onSelected: () async {
                          final linkedId = await getIdFromSavedRoute();
                          await createScreenshot(linkedId: linkedId);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              PlatformMenu(
                label: localizations.editMenuTitle,
                menus: [],
              ),
              PlatformMenu(
                label: localizations.viewMenuTitle,
                menus: [
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.toggleFullScreen,
                  ),
                  const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.zoomWindow,
                  ),
                  PlatformMenuItemGroup(
                    members: [
                      PlatformMenuItem(
                        label: snapshot.data?.contains(showBrightSchemeFlag) ??
                                false
                            ? localizations.viewMenuDisableBrightTheme
                            : localizations.viewMenuEnableBrightTheme,
                        shortcut: const SingleActivator(
                          LogicalKeyboardKey.keyS,
                          meta: true,
                          alt: true,
                        ),
                        onSelected: () async {
                          await _db.toggleConfigFlag(showBrightSchemeFlag);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
            child: child,
          );
        },
      ),
    );
  }
}
