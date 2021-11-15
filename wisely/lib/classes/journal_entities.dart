import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wisely/classes/geolocation.dart';
import 'package:wisely/classes/health.dart';
import 'package:wisely/classes/task.dart';
import 'package:wisely/sync/vector_clock.dart';

import 'check_list_item.dart';
import 'entry_text.dart';

part 'journal_entities.freezed.dart';
part 'journal_entities.g.dart';

@freezed
class Metadata with _$Metadata {
  factory Metadata({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime dateFrom,
    required DateTime dateTo,
    int? utcOffset,
    String? timezone,
    VectorClock? vectorClock,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, dynamic> json) =>
      _$MetadataFromJson(json);
}

@freezed
class ImageData with _$ImageData {
  factory ImageData({
    required DateTime capturedAt,
    required String imageId,
    required String imageFile,
    required String imageDirectory,
    Geolocation? geolocation,
  }) = _ImageData;

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);
}

@freezed
class AudioData with _$AudioData {
  factory AudioData({
    required DateTime dateFrom,
    required DateTime dateTo,
    required String audioFile,
    required String audioDirectory,
    required Duration duration,
    String? transcript,
  }) = _AudioData;

  factory AudioData.fromJson(Map<String, dynamic> json) =>
      _$AudioDataFromJson(json);
}

@freezed
class JournalEntity with _$JournalEntity {
  factory JournalEntity.journalEntry({
    required Metadata meta,
    required EntryText entryText,
    Geolocation? geolocation,
  }) = JournalEntry;

  const factory JournalEntity.journalImage({
    required Metadata meta,
    required ImageData data,
    EntryText? entryText,
    Geolocation? geolocation,
  }) = JournalImage;

  const factory JournalEntity.journalAudio({
    required Metadata meta,
    required AudioData data,
    EntryText? entryText,
    Geolocation? geolocation,
  }) = JournalAudio;

  const factory JournalEntity.loggedTime({
    required Metadata meta,
    EntryText? entryText,
    Geolocation? geolocation,
  }) = LoggedTime;

  const factory JournalEntity.task({
    required Metadata meta,
    EntryText? entryText,
    Geolocation? geolocation,
    required TaskStatus status,
    required List<TaskStatus> statusHistory,
    required String title,
    List<CheckListItem>? checklist,
  }) = Task;

  const factory JournalEntity.quantitative({
    required Metadata meta,
    required QuantitativeData data,
  }) = QuantitativeEntry;

  factory JournalEntity.fromJson(Map<String, dynamic> json) =>
      _$JournalEntityFromJson(json);
}
