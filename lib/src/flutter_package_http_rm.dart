import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'http_rm_configuration.dart';
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

  bool isShowLog ; // 单个添加
  bool isOpenCook ; //单个添加是否保存cook
  Map<String, dynamic>headsMap; //单个添加http的heads头

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
        bool isShowLog, bool isOpenCook,
        this.headsMap,
      }) : this.isShowLog = isShowLog ?? HTTP_RM_CONFIGURATION.isHttpOpenLog , this.isOpenCook = isOpenCook ?? HTTP_RM_CONFIGURATION.isHttpOpenCook {

    const bool inProduction = const bool.fromEnvironment("dart.vm.product"); //判断是否release还是debug环境

    String httpUrl;

    if (HTTP_RM_CONFIGURATION.baseHttpURL.isEmpty) {
      if (inProduction) {
        httpUrl = HTTP_RM_CONFIGURATION.baseReleaseHttpURL;
      } else {
        httpUrl = HTTP_RM_CONFIGURATION.baseDebugHttpURL;
      }
    } else {
      httpUrl = HTTP_RM_CONFIGURATION.baseHttpURL;
    }

    Map <String, dynamic>heads = HTTP_RM_CONFIGURATION.headsMap;
    if (this.headsMap != null) {
      heads = this.headsMap;
    }


    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    options = BaseOptions(
      //请求基地址,可以包含子路径

        baseUrl: httpUrl,
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 10000,
        //响应流上前后两次接受到数据的间隔，单位为毫秒。
        receiveTimeout: 5000,
        //Http请求头.
        headers: heads

      //请求的Content-Type，默认值是[ContentType.json]. 也可以用ContentType.parse("application/x-www-form-urlencoded")
//      contentType: ContentType.json,
      //表示期望以那种格式(方式)接受响应数据。接受四种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
//      responseType: ResponseType.plain,
    );

    dio = Dio(options);

    if (this.isShowLog ) {
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
    ResponseData responseNew = ResponseData();
    Response response;
    try {
      response = await dio.get(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      responseNew.isSuccess = true;
      responseNew.response = response;
    } on DioError catch (e) {
      responseNew.isSuccess = false;
      responseNew.dioError = e;
      formatError(e);
    }
    return responseNew;
  }

  /*
   * post请求
   */
  post(url, {data, options, cancelToken}) async {
    ResponseData responseNew = ResponseData();
    Response response;
    try {
      response = await dio.post(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      responseNew.isSuccess = true;
      responseNew.response = response;
    } on DioError catch (e) {
      responseNew.isSuccess = false;
      responseNew.dioError = e;
      formatError(e);
    }
    return responseNew;
  }

  /*
   * 下载文件
   */
  downloadFile(urlPath, savePath) async {
    ResponseData responseNew = ResponseData();
    Response response;
    try {
      response = await dio.download(urlPath, savePath,
          onReceiveProgress: (int count, int total) {
            //进度
            print("$count $total");
          });
      responseNew.isSuccess = true;
      responseNew.response = response;
    } on DioError catch (e) {
      responseNew.isSuccess = false;
      responseNew.dioError = e;
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

//整体返回的数据
class ResponseData {
  Response response; // 返回正常的数据
  bool isSuccess = false; //是否请求数据成功
  DioError dioError; // 错误的信息
}
