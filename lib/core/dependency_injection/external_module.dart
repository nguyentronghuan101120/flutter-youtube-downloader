import 'package:injectable/injectable.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';

@module
abstract class ExternalModule {
  @lazySingleton
  YoutubeExplode get youtubeExplode => YoutubeExplode();

  @lazySingleton
  Uuid get uuid => const Uuid();

  @lazySingleton
  Dio get dio => Dio();
}
