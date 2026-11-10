import '../../../core/widgets/app_icon.dart';
import '../domain/queue_item.dart';

AppIconName queueSourceIcon(QueueSource source) => switch (source) {
  QueueSource.galleryShare => AppIconName.image,
  QueueSource.galleryPicker => AppIconName.image,
  QueueSource.pinterest => AppIconName.cloud,
  QueueSource.genericUrl => AppIconName.link,
  QueueSource.directImageLink => AppIconName.link,
  QueueSource.manualFile => AppIconName.folder,
};
