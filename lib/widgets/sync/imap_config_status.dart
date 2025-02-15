import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lotti/blocs/sync/sync_config_cubit.dart';
import 'package:lotti/blocs/sync/sync_config_state.dart';
import 'package:lotti/themes/theme.dart';

class ImapConfigStatus extends StatelessWidget {
  const ImapConfigStatus({
    super.key,
    this.showText = true,
  });

  final bool showText;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<SyncConfigCubit, SyncConfigState>(
      builder: (context, SyncConfigState state) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showText)
                state.when(
                  configured: (_, __) =>
                      StatusText(loc.syncAssistantStatusSuccess),
                  imapSaved: (_) => StatusText(loc.syncAssistantStatusSaved),
                  imapValid: (_) => StatusText(loc.syncAssistantStatusValid),
                  imapTesting: (_) =>
                      StatusText(loc.syncAssistantStatusTesting),
                  imapInvalid: (_, String errorMessage) =>
                      StatusText(errorMessage),
                  loading: () => StatusText(loc.syncAssistantStatusLoading),
                  generating: () =>
                      StatusText(loc.syncAssistantStatusGenerating),
                  empty: () => StatusText(loc.syncAssistantStatusEmpty),
                ),
              state.when(
                configured: (_, __) =>
                    StatusIndicator(styleConfig().primaryColor),
                imapValid: (_) => StatusIndicator(styleConfig().primaryColor),
                imapSaved: (_) => StatusIndicator(styleConfig().primaryColor),
                imapTesting: (_) =>
                    StatusIndicator(styleConfig().primaryColorLight),
                imapInvalid: (_, __) => StatusIndicator(styleConfig().alarm),
                loading: () => const StatusIndicator(Colors.grey),
                generating: () => const StatusIndicator(Colors.grey),
                empty: () => const StatusIndicator(Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatusText extends StatelessWidget {
  const StatusText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: formLabelStyle(),
    );
  }
}

class StatusIndicator extends StatelessWidget {
  const StatusIndicator(
    this.statusColor, {
    super.key,
  });

  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: statusColor,
            blurRadius: 5,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }
}
