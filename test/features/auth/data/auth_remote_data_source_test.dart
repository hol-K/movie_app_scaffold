import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';

class _CallbackAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) callback;

  _CallbackAdapter(this.callback);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      callback(options);

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
  late Dio dio;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://auth.test'));
    dataSource = AuthRemoteDataSourceImpl(dio);
  });

  test('login envoie les identifiants et construit la session', () async {
    dio.httpClientAdapter = _CallbackAdapter((options) async {
      expect(options.path, '/login');
      expect(options.data, {'email': 'eve@example.com', 'password': 'secret'});
      return _jsonResponse({'token': 'access-123'});
    });

    final result = await dataSource.login(
      email: 'eve@example.com',
      password: 'secret',
    );

    expect(result.user.id, 'access-123');
    expect(result.user.email, 'eve@example.com');
    expect(result.accessToken, 'access-123');
    expect(result.refreshToken, 'access-123-refresh');
  });

  test('register lit l’identifiant renvoyé par ReqRes', () async {
    dio.httpClientAdapter = _CallbackAdapter((options) async {
      expect(options.path, '/register');
      return _jsonResponse({'id': 7, 'token': 'registered-token'});
    });

    final result = await dataSource.register(
      email: 'eve@example.com',
      password: 'secret',
    );

    expect(result.user.id, '7');
    expect(result.accessToken, 'registered-token');
  });

  test('mappe une réponse 401 en AuthException', () async {
    dio.httpClientAdapter = _CallbackAdapter((_) async {
      return _jsonResponse({'error': 'user not found'}, statusCode: 401);
    });

    expect(
      () => dataSource.login(email: 'bad@example.com', password: 'wrong'),
      throwsA(
        isA<AuthException>().having(
          (exception) => exception.message,
          'message',
          'user not found',
        ),
      ),
    );
  });

  test('rafraîchit uniquement un refresh token simulé valide', () async {
    expect(await dataSource.refreshToken('access-123-refresh'), 'access-123');
    expect(
      () => dataSource.refreshToken('invalid-token'),
      throwsA(isA<AuthException>()),
    );
  });
}
