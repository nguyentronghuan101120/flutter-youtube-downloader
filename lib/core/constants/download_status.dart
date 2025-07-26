import 'package:flutter/material.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed }

extension DownloadStatusExtension on DownloadStatus {
  IconData get icon {
    switch (this) {
      case DownloadStatus.queued:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case DownloadStatus.queued:
        return Theme.of(context).colorScheme.outline;
      case DownloadStatus.downloading:
        return Theme.of(context).colorScheme.primary;
      case DownloadStatus.paused:
        return Theme.of(context).colorScheme.secondary;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }

  String get text {
    switch (this) {
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  String get displayName {
    switch (this) {
      case DownloadStatus.queued:
        return 'QUEUED';
      case DownloadStatus.downloading:
        return 'DOWNLOADING';
      case DownloadStatus.paused:
        return 'PAUSED';
      case DownloadStatus.completed:
        return 'COMPLETED';
      case DownloadStatus.failed:
        return 'FAILED';
    }
  }

  String get statusDisplayName {
    switch (this) {
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
    }
  }

  IconData get emptyStateIcon {
    switch (this) {
      case DownloadStatus.queued:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.failed:
        return Icons.error;
    }
  }
}
