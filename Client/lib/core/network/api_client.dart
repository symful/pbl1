import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          // Removing receiveTimeout as requested for slow AI generations
        ));

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response<ResponseBody>> postStream(String path, {dynamic data}) async {
    return await _dio.post<ResponseBody>(
      path,
      data: data,
      options: Options(responseType: ResponseType.stream),
    );
  }

  Future<Response> postMultipart(String path, {required FormData formData}) async {
    return await _dio.post(path, data: formData);
  }

  Future<Response<List<int>>> postBytes(String path, {dynamic data}) async {
    return await _dio.post<List<int>>(
      path,
      data: data,
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
