import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

@module
abstract class ExternalModule {
  @lazySingleton
  YoutubeExplode get youtubeExplode => YoutubeExplode();
}
