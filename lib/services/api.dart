import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';

class ApiService {
  // LOCAL = http://192.168.121.81:8000
  // DEV = https://apiis.idcapps.net
  // PROD = https://apiis.icapps.id
  final baseUrl = 'https://apiis.idcapps.net';
  final company = 'IC';
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/api',
        headers: {
          'Accept': 'application/json',
          'Connection': 'Keep-Alive',
          'company': company,
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )..interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        logPrint: (o) => debugPrint(o.toString(), wrapWidth: 1024),
      ));
  }

  static String? _token;

  String get getToken {
    return _token ?? '';
  }

  set setToken(String token) {
    _token = token;
  }

  Future<Either<Map, AuthModel>> register(name, email, pswd) async {
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.post('/register',
          data: json.encode(<String, dynamic>{
            'name': name,
            'email': email,
            'password': pswd,
            'password_confirmation': pswd,
          }));
      var data = AuthModel.fromJson(Map<String, dynamic>.from(res.data as Map));
      _token = data.token;
      return Right(data);
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, AuthModel>> login(user, pswd) async {
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.post('/login',
          data: json.encode(<String, dynamic>{
            'email': company + user,
            'password': pswd,
          }));
      var data = AuthModel.fromJson(Map<String, dynamic>.from(res.data as Map));
      _token = data.token;
      return Right(data);
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> logout() async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.post('/logout');
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, ProfileModel>> getProfile() async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.get('/profile');
      return Right(
          ProfileModel.fromJson(Map<String, dynamic>.from(res.data as Map)));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> changeProfile(File? pict) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.post('/profile',
          data: FormData.fromMap({
            'foto': await MultipartFile.fromFile(pict!.path),
          }));
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> changePassword(oldPswd, newPswd) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.post('/change-password',
          data: json.encode(<String, dynamic>{
            'old_password': oldPswd,
            'new_password': newPswd,
            'new_password_confirmation': newPswd,
          }));
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> getMaster(name) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.get('/master/$name?limit=10000');
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> getTran(name) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.get('/tran/$name?limit=10000');
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> getDetail(name) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.get('/detail/$name?limit=10000');
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  Future<Either<Map, Map>> getAction(name) async {
    dio.options.headers['Authorization'] = 'Bearer $_token';
    try {
      var con = await Connectivity().checkConnectivity();
      if (con.contains(ConnectivityResult.wifi) == false &&
          con.contains(ConnectivityResult.mobile) == false) {
        return const Left({'message': 'No internet access!'});
      }

      var res = await dio.get('/action/$name?limit=10000');
      return Right(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (err) {
      return Left(errorHandler(err));
    }
  }

  dynamic errorHandler(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout) {
      return <String, dynamic>{'message': 'Connect timeout'};
    }

    if (err.type == DioExceptionType.receiveTimeout) {
      return <String, dynamic>{'message': 'Receive timeout'};
    }

    if (err.type == DioExceptionType.badResponse) {
      var res = Map<String, dynamic>.from(jsonDecode(err.response.toString()));
      if ((res['message'] ?? '') != '') {
        return <String, dynamic>{'message': res['message']};
      }
      if ((res['detail'] ?? '') != '') {
        return <String, dynamic>{'message': res['detail']};
      }
      if ((res['password'] ?? '') != '' &&
          (res['password'] as List).isNotEmpty) {
        return <String, dynamic>{'message': res['password'][0]};
      }
    }

    if (err.response == null) {
      return <String, dynamic>{'message': err.message.toString()};
    }

    return Map<String, dynamic>.from(jsonDecode(err.response.toString()));
  }
}
