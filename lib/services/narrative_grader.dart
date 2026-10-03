import 'dart:convert';
import 'package:http/http.dart' as http;
import 'account_service.dart';

class NarrativeGrade {
  NarrativeGrade.fromJson(Map<String, dynamic> data)
    : score = data['score'] as int,
      feedback = data['feedback'] as String,
      improvements = (data['improvements'] as List).cast<String>(),
      abilities = {
        for (final key in [
          'accuracy',
          'priorities',
          'reasoning',
          'verification',
        ])
          if (data[key] is int) key: data[key] as int,
      },
      assessmentNote = data['assessmentNote'] as String?,
      engine = data['engine'] as String? ?? 'openai',
      answer = data['answer'] as String {
    if (score < 0 || score > 100) throw const FormatException('Invalid score');
  }
  final int score;
  final String feedback;
  final List<String> improvements;
  final String answer;
  final Map<String, int> abilities;
  final String? assessmentNote;
  final String engine;
  String get skillLevel => score < 20
      ? 'Awam'
      : score < 40
      ? 'Dasar'
      : score < 60
      ? 'Menengah'
      : score < 80
      ? 'Lanjutan'
      : 'Pro';
}

abstract class NarrativeGrader {
  Future<NarrativeGrade?> load(String questionId);
  Future<NarrativeGrade> grade(String questionId, String answer);
}

class GradingFailure implements Exception {
  const GradingFailure(this.message);
  final String message;
}

class LocalNarrativeGrader implements NarrativeGrader {
  static const _base = String.fromEnvironment(
    'GRADING_API_URL',
    defaultValue: 'http://127.0.0.1:8787',
  );

  Future<Map<String, String>> _headers() async {
    final user = AccountService.configured
        ? AccountService.auth.currentUser
        : null;
    if (user == null) {
      throw const GradingFailure('Login diperlukan untuk penilaian.');
    }
    final token = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<NarrativeGrade?> _request(
    String path, {
    String? answer,
    String? questionId,
  }) async {
    try {
      final headers = await _headers();
      final uri = Uri.parse('$_base$path');
      final response =
          await (answer == null
                  ? http.get(uri, headers: headers)
                  : http.post(
                      uri,
                      headers: headers,
                      body: jsonEncode({
                        'questionId': questionId,
                        'answer': answer,
                      }),
                    ))
              .timeout(const Duration(seconds: 55));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        final message = switch (data['error']) {
          'api-not-configured' =>
            'API key backend belum diisi. Jalankan start_grading.ps1.',
          'api-quota' =>
            'Saldo atau kuota OpenAI API belum tersedia. ChatGPT Plus tidak menyediakan saldo API.',
          'api-key' => 'API key backend tidak valid. Masukkan key baru.',
          'rate-limit' => 'Batas penilaian tercapai. Coba lagi nanti.',
          'provider-rate-limit' =>
            'OpenAI sedang membatasi permintaan. Tunggu sebentar sebelum mencoba lagi; periksa batas API pada akun OpenAI.',
          'local-rate-limit' =>
            'Batas demo 20 penilaian per akun per jam tercapai. Coba lagi setelah satu jam.',
          'grading-busy' =>
            'Penilaian sebelumnya masih berjalan. Tunggu hingga selesai.',
          'unauthorized' => 'Sesi akun tidak valid. Login ulang.',
          'invalid-grade' =>
            'Model belum menghasilkan penilaian lengkap. Coba lagi.',
          _ => 'Penilaian belum berhasil. Coba lagi.',
        };
        throw GradingFailure(message);
      }
      return data['result'] == null
          ? null
          : NarrativeGrade.fromJson(data['result'] as Map<String, dynamic>);
    } on GradingFailure {
      rethrow;
    } catch (_) {
      throw const GradingFailure(
        'Backend penilaian belum terhubung. Jalankan backend dan periksa koneksi.',
      );
    }
  }

  @override
  Future<NarrativeGrade?> load(String questionId) =>
      _request('/grades/${Uri.encodeComponent(questionId)}');

  @override
  Future<NarrativeGrade> grade(String questionId, String answer) async {
    final result = await _request(
      '/grade',
      questionId: questionId,
      answer: answer,
    );
    if (result == null) {
      throw const GradingFailure('Penilaian belum tersedia. Coba lagi.');
    }
    return result;
  }
}
