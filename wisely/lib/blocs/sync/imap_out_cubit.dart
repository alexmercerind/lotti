import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail/imap/imap_client.dart';
import 'package:enough_mail/imap/response.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:wisely/blocs/sync/encryption_cubit.dart';
import 'package:wisely/blocs/sync/imap/create_client.dart';
import 'package:wisely/blocs/sync/imap_state.dart';
import 'package:wisely/blocs/sync/imap_tools.dart';
import 'package:wisely/utils/image_utils.dart';

class ImapOutCubit extends Cubit<ImapState> {
  late final EncryptionCubit _encryptionCubit;
  late String? _b64Secret;

  final String sharedSecretKey = 'sharedSecret';
  final String imapConfigKey = 'imapConfig';
  final String lastReadUidKey = 'lastReadUid';

  ImapOutCubit({
    required EncryptionCubit encryptionCubit,
  }) : super(ImapState.initial()) {
    _encryptionCubit = encryptionCubit;
  }

  Future<bool> saveImap(
    String encryptedMessage,
    String subject, {
    String? encryptedFilePath,
  }) async {
    ImapClient? imapClient;
    try {
      final transaction = Sentry.startTransaction('saveImap()', 'task');
      imapClient = await createImapClient(_encryptionCubit);

      GenericImapResult? res;
      if (_b64Secret != null && imapClient != null) {
        if (encryptedFilePath != null && encryptedFilePath.isNotEmpty) {
          File encryptedFile = File(await getFullAssetPath(encryptedFilePath));
          int fileLength = encryptedFile.lengthSync();
          if (fileLength > 0) {
            res = await saveImapMessage(imapClient, subject, encryptedMessage,
                file: encryptedFile);
          }
        } else {
          res = await saveImapMessage(imapClient, subject, encryptedMessage);
        }
      }
      await transaction.finish();

      String? resDetails = res?.details;
      await Sentry.captureEvent(
          SentryEvent(
            message: SentryMessage(
              resDetails ?? 'no result details',
            ),
          ),
          withScope: (Scope scope) => scope.level = SentryLevel.info);

      if (resDetails != null && resDetails.contains('completed')) {
        return true;
      } else {
        return false;
      }
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      await imapClient?.disconnect();
    }
  }
}
