import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';
import 'package:vocabu_rex_mobile/network/interceptors/auth_interceptor.dart';

class ExerciseService extends BaseApiService {
  // Singleton pattern
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();
  Future<Map<String, dynamic>> getExercisesByLessonId(String lessonId) async {
    try {
      final response = await client.get('${ApiEndpoints.exercise}$lessonId');
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getReviewExercises() async {
    try {
      final response = await client.get('${ApiEndpoints.exerciseReview}');
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getPronunExercises() async {
    try {
      final response = await client.get('${ApiEndpoints.exercisePronun}');
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> submitExersiceResult(
    ExerciseResultEntity result,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.submit}',
        data: result.toJson(),
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> submitPronunExersiceResult(
    ExerciseResultEntity result,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.submitPronun}',
        data: result.toJson(),
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> imgDescriptionScore(
    String content,
    String expectResult,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.imgDescription}',
        data: {
          "user_content": content,
          "expected_results": expectResult,
          "language": "en",
        },
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> translateScore(
    String user_answer,
    String source_text,
    String correct_answer,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.translateScore}',
        data: {
          "user_answer": user_answer,
          "source_text": source_text,
          "correct_answer": correct_answer,
          "language": "en",
        },
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> writingScore(
    String user_answer,
    WritingPromptMetaEntity meta,
  ) async {
    try {
      final response = await client.post(
        '${ApiEndpoints.writingScore}',
        data: {
          "user_answer": user_answer,
          "exercise_meta": meta.toJson(),
          "language": "en",
        },
      );
      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> speakCheck(
    String filePath,
    String reference_text,
  ) async {
    try {
      if (!await File(filePath).exists()) {
        throw Exception("File âm thanh không tồn tại: $filePath");
      }
      // Kiểm tra tính hợp lệ của file (Bước này rất quan trọng)
      if (!await File(filePath).exists()) {
        throw Exception(
          "Lỗi: File âm thanh không tồn tại tại đường dẫn: $filePath",
        );
      }

      // 1. Tạo MultipartFile với MIME Type chính xác cho M4A
      final audioFile = await MultipartFile.fromFile(
        filePath,

        // Đảm bảo tên file có đuôi mở rộng .m4a
        filename: filePath.split('/').last,

        // Đặt ContentType là 'audio/mp4' (hoặc 'audio/m4a').
        // 'audio/mp4' là chuẩn chung cho M4A.
        contentType: DioMediaType('audio', 'x-m4a'),
      );

      // 2. TẠO FormData RÕ RÀNG VÀ CHÍNH XÁC
      final formData = FormData();

      // Thêm các trường văn bản (key không cần dấu '[]' vì là giá trị đơn)
      formData.fields.addAll([
        MapEntry("reference_text", reference_text),
        MapEntry("language", "english"),
        MapEntry("model_size", "base"),
      ]);

      // Thêm file: Tên key PHẢI LÀ "audio_file"
      formData.files.add(MapEntry("audio_file", audioFile));

      // 3. Gửi request
      final res = await client.post(
        '${ApiEndpoints.speakCheck}',
        data: formData,
      );
      return res.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
