import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_youtube_downloader/domain/entities/video_info.dart';
import 'package:flutter_youtube_downloader/domain/repositories/video_repository.dart';
import 'package:flutter_youtube_downloader/domain/usecases/analyze_video.dart';
import 'package:flutter_youtube_downloader/core/error/failures.dart';

import 'analyze_video_test.mocks.dart';

@GenerateMocks([VideoRepository])
void main() {
  late AnalyzeVideoUseCase useCase;
  late MockVideoRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoRepository();
    useCase = AnalyzeVideoUseCase(mockRepository);
  });

  const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  const testVideoInfo = VideoInfo(
    id: 'dQw4w9WgXcQ',
    title: 'Test Video',
    description: 'Test Description',
    duration: Duration(minutes: 3, seconds: 33),
    channelName: 'Test Channel',
    channelId: 'UC123456789',
    thumbnailUrl: 'https://example.com/thumbnail.jpg',
    videoStreams: [],
    audioStreams: [],
    subtitles: [],
  );

  group('AnalyzeVideoUseCase', () {
    test(
      'should return VideoInfo when repository call is successful',
      () async {
        // arrange
        when(
          mockRepository.analyzeVideo(testUrl),
        ).thenAnswer((_) async => const Right(testVideoInfo));

        // act
        final result = await useCase(testUrl);

        // assert
        expect(result, const Right(testVideoInfo));
        verify(mockRepository.analyzeVideo(testUrl));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return ServerFailure when repository call fails', () async {
      // arrange
      const failure = ServerFailure('Server error');
      when(
        mockRepository.analyzeVideo(testUrl),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.analyzeVideo(testUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return InvalidInputFailure for invalid URL format', () async {
      // arrange
      const invalidUrl = 'invalid-url';
      const failure = InvalidInputFailure('Invalid URL format');
      when(
        mockRepository.analyzeVideo(invalidUrl),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(invalidUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.analyzeVideo(invalidUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return VideoUnavailableFailure for unavailable video',
      () async {
        // arrange
        const failure = VideoUnavailableFailure(
          'Video is unavailable or private',
        );
        when(
          mockRepository.analyzeVideo(testUrl),
        ).thenAnswer((_) async => const Left(failure));

        // act
        final result = await useCase(testUrl);

        // assert
        expect(result, const Left(failure));
        verify(mockRepository.analyzeVideo(testUrl));
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return NetworkFailure for network errors', () async {
      // arrange
      const failure = NetworkFailure('Network error');
      when(
        mockRepository.analyzeVideo(testUrl),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.analyzeVideo(testUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle empty URL', () async {
      // arrange
      const emptyUrl = '';
      const failure = InvalidInputFailure('URL cannot be empty');
      when(
        mockRepository.analyzeVideo(emptyUrl),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(emptyUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.analyzeVideo(emptyUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle null URL', () async {
      // arrange
      const nullUrl = null;
      const failure = InvalidInputFailure('URL cannot be null');
      when(
        mockRepository.analyzeVideo(nullUrl),
      ).thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase(nullUrl);

      // assert
      expect(result, const Left(failure));
      verify(mockRepository.analyzeVideo(nullUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle YouTube playlist URLs', () async {
      // arrange
      const playlistUrl = 'https://www.youtube.com/playlist?list=PL123456789';
      when(
        mockRepository.analyzeVideo(playlistUrl),
      ).thenAnswer((_) async => const Right(testVideoInfo));

      // act
      final result = await useCase(playlistUrl);

      // assert
      expect(result, const Right(testVideoInfo));
      verify(mockRepository.analyzeVideo(playlistUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle YouTube short URLs', () async {
      // arrange
      const shortUrl = 'https://youtu.be/dQw4w9WgXcQ';
      when(
        mockRepository.analyzeVideo(shortUrl),
      ).thenAnswer((_) async => const Right(testVideoInfo));

      // act
      final result = await useCase(shortUrl);

      // assert
      expect(result, const Right(testVideoInfo));
      verify(mockRepository.analyzeVideo(shortUrl));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle repository exceptions', () async {
      // arrange
      when(
        mockRepository.analyzeVideo(testUrl),
      ).thenThrow(Exception('Unexpected error'));

      // act
      final result = await useCase(testUrl);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (videoInfo) => fail('Should return failure'),
      );
      verify(mockRepository.analyzeVideo(testUrl));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
