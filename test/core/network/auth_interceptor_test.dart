import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/network/auth_interceptor.dart';
import 'package:movie_app/core/storage/token_storage.dart';

class _MockTokenStorage extends Mock implements TokenStorage {}

class _SequenceAdapter implements HttpClientAdapter {
  final List<ResponseBody> responses;

  _SequenceAdapter(this.responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(responses, isNotEmpty);
    return responses.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late _MockTokenStorage tokenStorage;

  setUp(() {
    tokenStorage = _MockTokenStorage();
  });

  test('ajoute le Bearer et rejoue une requête après un 401', () async {
    when(() => tokenStorage.accessToken).thenAnswer((_) async => 'old-token');
    when(() => tokenStorage.refreshToken)
        .thenAnswer((_) async => 'refresh-token');
    when(() => tokenStorage.saveTokens(accessToken: 'new-token'))
        .thenAnswer((_) async {});

    final retryDio = Dio(BaseOptions(baseUrl: 'https://movies.test'));
    retryDio.httpClientAdapter = _SequenceAdapter([
      _jsonResponse({'title': 'Film récupéré'}),
    ]);

    final dio = Dio(BaseOptions(baseUrl: 'https://movies.test'));
    dio.httpClientAdapter = _SequenceAdapter([
      _jsonResponse({'error': 'expired'}, statusCode: 401),
    ]);
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onRefreshToken: (_) async => 'new-token',
        baseUrl: 'https://movies.test',
        retryDio: retryDio,
      ),
    );

    final response = await dio.get('/popular');

    expect(response.statusCode, 200);
    expect(response.data['title'], 'Film récupéré');
    verify(() => tokenStorage.saveTokens(accessToken: 'new-token')).called(1);
  });

  test('purge la session quand le refresh est impossible', () async {
    when(() => tokenStorage.accessToken).thenAnswer((_) async => 'old-token');
    when(() => tokenStorage.refreshToken).thenAnswer((_) async => null);
    when(() => tokenStorage.clear()).thenAnswer((_) async {});

    final dio = Dio(BaseOptions(baseUrl: 'https://movies.test'));
    dio.httpClientAdapter = _SequenceAdapter([
      _jsonResponse({'error': 'expired'}, statusCode: 401),
    ]);
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        onRefreshToken: (_) async => 'new-token',
        baseUrl: 'https://movies.test',
      ),
    );

    await expectLater(
      dio.get('/popular'),
      throwsA(isA<DioException>()),
    );
    verify(() => tokenStorage.clear()).called(1);
    verifyNever(
        () => tokenStorage.saveTokens(accessToken: any(named: 'accessToken')));
  });
}
