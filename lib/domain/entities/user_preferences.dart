import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class UserPreferences extends Equatable {
  final DownloadType downloadType;
  final String selectedFormat;
  final String selectedQuality;

  const UserPreferences({
    required this.downloadType,
    required this.selectedFormat,
    required this.selectedQuality,
  });

  @override
  List<Object?> get props => [downloadType, selectedFormat, selectedQuality];

  UserPreferences copyWith({
    DownloadType? downloadType,
    String? selectedFormat,
    String? selectedQuality,
  }) {
    return UserPreferences(
      downloadType: downloadType ?? this.downloadType,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedQuality: selectedQuality ?? this.selectedQuality,
    );
  }
}
