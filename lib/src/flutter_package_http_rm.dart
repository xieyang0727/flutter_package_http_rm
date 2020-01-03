import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'http_rm_configuration.dart';
import 'package:flutter/material.dart';
import 'http_rm_error.dart';
import 'http_rm_result_data.dart';
import 'http_rm_options.dart';

typedef DefaultCallbackRM = void Function();
typedef ParameterErrorCallbackRM = void Function(DioError dioError);
typedef ParameterResultCallbackRM = RMError Function(Response object);

class HttpUtilRM {
  static HttpUtilRM instance;
  Dio dio;
  BaseOptions options;
  CancelToken cancelToken = CancelToken();
  DefaultCallbackRM onRequestBefore; //请求之前
  DefaultCallbackRM onRequestErrorBefore; //请求出错误了
  DefaultCallbackRM onResponseBefore; //响应之前
  ParameterErrorCallbackRM parameterErrorCallbackRM; //整体返回一个错误码
  ParameterResultCallbackRM onClientCodeJudgeCallBack; //数据响应

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
      BaseOptions customOptions,
      this.onClientCodeJudgeCallBack})
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
      //判断外边是否对数据做特殊处理
      if (judgeClientCode(response, url) != null) {
        return judgeClientCode(response, url);
      }
      responseNew = ResponseDataRM(true, url: url, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false,
          url: url,
          rmError: RMError(
              rmErrorType: RMErrorType.NET,
              dioError: e,
              msg: HTTP_RM_CONFIGURATION.errorNetDefault));
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
      //请求数据
      Response response = await dio.post(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
//判断外边是否对数据做特殊处理
      if (judgeClientCode(response, url) != null) {
        return judgeClientCode(response, url);
      }
      responseNew = ResponseDataRM(true, url: url, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false,
          url: url,
          rmError: RMError(
              rmErrorType: RMErrorType.NET,
              dioError: e,
              msg: HTTP_RM_CONFIGURATION.errorNetDefault));

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
      //判断外边是否对数据做特殊处理
      Response response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
        //进度
        print("$count $total");
      });
      if (judgeClientCode(response, urlPath) != null) {
        return judgeClientCode(response, urlPath);
      }
      responseNew = ResponseDataRM(true, url: urlPath, response: response);
    } on DioError catch (e) {
      responseNew = ResponseDataRM(false,
          url: urlPath,
          rmError: RMError(
              rmErrorType: RMErrorType.NET,
              dioError: e,
              msg: HTTP_RM_CONFIGURATION.errorNetDefault));
      formatError(e);
    }
    return responseNew;
  }


  /*
   * 判断客户端是否有对code做整体判断
   */

  ResponseDataRM judgeClientCode(Response response, String url) {
    if (this.onClientCodeJudgeCallBack != null) {
      RMError rmError = this.onClientCodeJudgeCallBack(response);
      if (rmError != null) {
        return ResponseDataRM(false, url: url, rmError: rmError);
      }
    }
    return null;
  }

  /*
   * 网络error统一处理
   */
  void formatError(DioError e) {
    if (HTTP_RM_CONFIGURATION.isHttpOpenLog) {
      print("网络请求错误DioError $e ");
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
