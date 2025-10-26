import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:recomart/services/app_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseClient {
  static const String baseUrl = 'http://localhost:3000/'; 
  
  static const int timeOutDuration = 30;
  late Dio dio;

  BaseClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: timeOutDuration),
        receiveTimeout: const Duration(seconds: timeOutDuration),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));

    dio.options.validateStatus = (status) {
      if (status != null) {
        return status >= 200 && status < 300;
      }
      return false;
    };
  }

  Future<dynamic> _handleDioException(DioException e) async {
    if (e.response != null) {
      return _processResponse(e.response!);
    } else {
      // Bổ sung xử lý lỗi timeout và network cho trường hợp không có response
      if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
         throw ApiNotRespondingException('API timeout', e.requestOptions.uri.toString());
      }
      if (e.error is SocketException) {
         throw FetchDataException('No Internet connection', e.requestOptions.path);
      }
      throw FetchDataException('An error occurred', e.requestOptions.path);
    }
  }

  // Phương thức chung để xử lý yêu cầu
  Future<dynamic> _requestWrapper(Future<Response> Function() request, String api) async {
    final uri = Uri.parse('$baseUrl$api');
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      // Xử lý chung các lỗi DioException (bao gồm SocketException và Timeout)
      return _handleDioException(e);
    } on SocketException {
      // Trường hợp này có thể không cần thiết nếu DioException đã xử lý
      throw FetchDataException('No Internet connection', api);
    } on TimeoutException {
      // Trường hợp này có thể không cần thiết nếu DioException đã xử lý
      throw ApiNotRespondingException('API timeout', uri.toString());
    }
  }

  // GET Request
  Future<dynamic> get(String api, {Map<String, dynamic>? queryParameters}) async {
    return _requestWrapper(
      () => dio.get(api, queryParameters: queryParameters),
      api,
    );
  }

  // POST Request
  Future<dynamic> post(String api, Map<String, dynamic> body) async {
    return _requestWrapper(
      () => dio.post(api, data: body),
      api,
    );
  }

  // PUT Request
  Future<dynamic> put(String api, Map<String, dynamic> body) async {
    return _requestWrapper(
      () => dio.put(api, data: body),
      api,
    );
  }

  // DELETE Request
  Future<dynamic> delete(String api) async {
    return _requestWrapper(
      () => dio.delete(api),
      api,
    );
  }

  // PATCH Request
  Future<dynamic> patch(String api, Map<String, dynamic> body) async {
    return _requestWrapper(
      () => dio.patch(api, data: body),
      api,
    );
  }
  
  // Upload Request
  Future<dynamic> upload(String api, FormData data) async {
    final uri = Uri.parse('$baseUrl$api');
    try {
      final options = Options(
        headers: {'Accept': 'application/json', 'Content-Type': 'multipart/form-data'},
      );
      final response = await dio.post(uri.toString(), data: data, options: options);
      return response.data;
    } on DioException catch (e) {
       return _handleDioException(e);
    } on SocketException {
       throw FetchDataException('No Internet connection', api);
    } on TimeoutException {
       throw ApiNotRespondingException('API timeout', uri.toString());
    }
  }

  // Xử lý phản hồi dựa trên mã trạng thái
  dynamic _processResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        return response.data; // Thêm trường hợp thành công
      case 400:
        final message = _parseErrorMessage(response.data);
        print('Error Dio: $message');
        throw BadRequestException(message, response.requestOptions.path);
      case 401:
      case 403:
        final message = _parseErrorMessage(response.data);
        throw UnAuthorizedException(message, response.requestOptions.path);
      case 500:
        final message = _parseErrorMessage(response.data);
        print('Server error: $message, Response: ${response.data}');
        throw FetchDataException('Error occurred: ${response.statusCode}',
            response.requestOptions.uri.toString());
      default:
        throw FetchDataException(
            'Something went wrong: Status ${response.statusCode}', response.requestOptions.uri.toString());
    }
  }

  // Phân tích thông báo lỗi từ phản hồi
  String _parseErrorMessage(dynamic data) {
    if (data is String) {
      return data;
    }
    if (data is Map) {
      if (data['message'] is String) {
        return data['message'];
      }
      if (data['error'] is Map && data['error']['message'] is String) {
        return data['error']['message'];
      }
      if (data['error'] is String) {
        return data['error'];
      }
    }

    return 'Unexpected error occurred';
  }
}