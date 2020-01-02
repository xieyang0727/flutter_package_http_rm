import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'http_rm_configuration.dart';
import 'package:flutter/material.dart';
import 'http_rm_result_data.dart';
import 'http_rm_options.dart';

typedef DefaultCallbackRM = void Function();
typedef ParameterErrorCallbackRM = void Function(DioError dioError);

class HttpUtilRM {
  static HttpUtilRM instance;
  Dio dio;
  BaseOptions options;
  CancelToken cancelToken = CancelToken();
  DefaultCallbackRM onRequestBefore; //请求之前
  DefaultCallbackRM onRequestErrorBefore; //请求出错误了
  DefaultCallbackRM onResponseBefore; //响应之前
  ParameterErrorCallbackRM parameterErrorCallbackRM; //整体返回一个错误码

  bool isShowLog; // 单个添加
  bool isOpenCook; //单个添加是否保存cook
  Map<String, dynamic> headsMap; //单个添加http的heads头

  //添加dart语言特色链式方法调用
//  更改头
  set setHeadsMap(Map<String, dynamic> value) {
    headsMap = value;
    dio.options.headers = value;
  }

  Map<String, dynamic> get setHeadsMap => headsMap;

//  更改是否显示log日志
  set setIsShowLog(bool value) {
    isShowLog = value;
    if (value) {
      dio.interceptors.add(LogInterceptor(
          responseBody: true,
          request: true,
          requestHeader: true,
          responseHeader: true)); //开启请求日志
    }
  }

  bool get setIsShowLog => isShowLog;

  set setAddInterceptors(dynamic element) {
    dio.interceptors.add(element);
  }

  Interceptors get setAddInterceptors => dio.interceptors;

  /*
   * config it and create
   */
//  @required 是否必传 {}花括号
  HttpUtilRM(
      {Key key,
        this.onRequestBefore,
        this.onRequestErrorBefore,
        this.onResponseBefore,
        this.parameterErrorCallbackRM,
        bool isShowLog,
        bool isOpenCook,
        this.headsMap,
        BaseOptions customOptions})
      : this.isShowLog = isShowLog ?? HTTP_RM_CONFIGURATION.isHttpOpenLog,
        this.isOpenCook = isOpenCook ?? HTTP_RM_CONFIGURATION.isHttpOpenCook {
    if (customOptions == null) {
      options = OptionsRM().returnOption(headsMap);
    } else {
      options = customOptions;
    }

    dio = Dio(options);

    if (this.isShowLog) {
      dio.interceptors.add(LogInterceptor(
          responseBody: true,
          request: true,
          requestHeader: true,
          responseHeader: true)); //开启请求日志
    }

    if (this.isOpenCook) {
      //   CookieJar //内存中
      //   PersistCookieJar // 数据持久化 可选
      dio.interceptors.add(CookieManager(CookieJar()));
    }

    //添加拦截器
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      // Do something before request is sent
      if (onRequestBefore != null) {
        onRequestBefore();
      }
      return options; //continue
    }, onResponse: (Response response) {
      // Do something with response data
      if (onResponseBefore != null) {
        onResponseBefore();
      }
      return response; // continue
    }, onError: (DioError e) {
      // Do something with response error
      if (onRequestErrorBefore != null) {
        onRequestErrorBefore();
      }
      return e; //continue
    }));
  }

  /*
   * get请求
   */
  get(url, {data, options, cancelToken}) async {
    ResponseDataRM responseNew;
    try {
      Response response = await dio.get(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      responseNew = ResponseDataRM(true, url: url, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false, url: url, dioError: e);
      formatError(e);
    }
    return responseNew;
  }

  /*
   * post请求
   */
  post(url, {data, options, cancelToken}) async {
    ResponseDataRM responseNew;
    try {
      Response response = await dio.post(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      responseNew = ResponseDataRM(true, url: url, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false, url: url, dioError: e);
      formatError(e);
    }
    return responseNew;
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    ResponseDataRM responseNew;
    try {
      Response response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
            //进度
            print("$count $total");
          });
      responseNew = ResponseDataRM(true, url: urlPath, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false, url: urlPath, dioError: e);
      formatError(e);
    }
    return responseNew;
  }

  /*
   * error统一处理
   */
  void formatError(DioError e) {
    if (HTTP_RM_CONFIGURATION.isHttpOpenLog) {
      print("网络请求错误DioError $e ");
    }
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      // It occurs when url is opened timeout.
//      print("连接超时");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      // It occurs when url is sent timeout.
//      print("请求超时");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      //It occurs when receiving timeout
//      print("响应超时");
    } else if (e.type == DioErrorType.RESPONSE) {
      // When the server response, but with a incorrect status, such as 404, 503...
//      print("出现异常");
    } else if (e.type == DioErrorType.CANCEL) {
      // When the request is cancelled, dio will throw a error with this type.
//      print("请求取消");
    } else {
      //DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
//      print("未知错误");
    }
    if (parameterErrorCallbackRM != null) {
      parameterErrorCallbackRM(e);
    }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
