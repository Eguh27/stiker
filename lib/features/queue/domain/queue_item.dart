/// Model `import_queue` (db-schema.md). Domain murni, tanpa Flutter.
enum QueueStatus { downloading, processing, pending, failed, done }

enum QueueSource {
  galleryShare,
  galleryPicker,
  pinterest,
  genericUrl,
  directImageLink,
  manualFile,
}

class QueueItem {
  const QueueItem({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.sourceType,
    this.sourceUrl,
    this.errorMessage,
  });

  final String id;
  final String title;
  final QueueStatus status;
  final int progress;
  final QueueSource sourceType;
  final String? sourceUrl;
  final String? errorMessage;

  QueueItem copyWith({QueueStatus? status, int? progress}) => QueueItem(
    id: id,
    title: title,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    sourceType: sourceType,
    sourceUrl: sourceUrl,
    errorMessage: errorMessage,
  );
}

extension QueueStatusText on QueueStatus {
  String get label => switch (this) {
    QueueStatus.downloading => 'Downloading',
    QueueStatus.processing => 'Processing',
    QueueStatus.pending => 'Pending',
    QueueStatus.failed => 'Gagal',
    QueueStatus.done => 'Selesai',
  };
}

extension QueueSourceText on QueueSource {
  String get label => switch (this) {
    QueueSource.galleryShare => 'Galeri',
    QueueSource.galleryPicker => 'Galeri',
    QueueSource.pinterest => 'Pinterest',
    QueueSource.genericUrl => 'Link',
    QueueSource.directImageLink => 'Link',
    QueueSource.manualFile => 'File',
  };
}
