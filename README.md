# flutter_package_http_rm

## Flutter开发版本
 Flutter ( Channel master, v1.10.15-pre.351, on Mac OS X 10.14.6 18G84, locale
 zh-Hans-CN)

## 安装
引用头文件
```bash
import 'package:flutter_package_http_rm/flutter_package_http_rm.dart';
```

```bash
打开pubspec.yaml并将以下行添加到依赖项： (备注:yaml 需要前边有两个空格,否则Packages get失败)

  flutter_package_http_rm:
    git:
      url: 'https://github.com/xieyang0727/flutter_package_http_rm.git'

```

## flutter_package_http_rm 内部引用插件
```bash
  dio: 3.0.7  #dio版本

  cookie_jar: ^1.0.0    #cookie缓存

  dio_cookie_manager: ^1.0.0   #cookManager
```


## 使用方法

### 外部可选配置
```bash
//  baseHttpURL(如果配置了baseHttpURL读取配置的如果没有配置，那么根据debug和release自动读取baseReleaseHttpURL和baseDebugHttpURL)

HTTP_RM_CONFIGURATION.baseHttpURL="http://*****"; 

HTTP_RM_CONFIGURATION.baseReleaseHttpURL="http:***";

HTTP_RM_CONFIGURATION.baseDebugHttpURL="http:***";

    
HTTP_RM_CONFIGURATION.isHttpOpenLog=true; (不填写默认false)

HTTP_RM_CONFIGURATION.isHttpOpenCook=true(不填写默认false);

HTTP_RM_CONFIGURATION.headsMap ={
      "version": "1.0.0"
    };
    
HTTP_RM_CONFIGURATION.errorNetDefault="网络出错了";(选填)

```
方法调用
```bash 
void setUpHttp() async {
  HttpUtilRM httpUtilRM;

  BaseNetService() {
    //可以自定义options参数
//  BaseOptions options = BaseOptions(
//    //请求基地址,可以包含子路径
//      baseUrl: "http://172.17.8.168:8080/CRDemo/",
//      //连接服务器超时时间，单位是毫秒.
//      connectTimeout: 10000,
//      //响应流上前后两次接受到数据的间隔，单位为毫秒。
//      receiveTimeout: 5000,
//      //Http请求头.
//      headers: {"version": "1.0.1"});

//以下参数均可以添加也可以不添加

    httpUtilRM = HttpUtilRM(
//      onRequestBefore: () {
//    print('开始网络请求了');
//  },
//      onRequestErrorBefore: () {
//    print('将要出错误了');
//  },
//      onResponseBefore: () {
//    print('网络响应之前');
//  },
//      parameterErrorCallbackRM: (DioError e) {
//    print('网络出错误了回调 $e');
//  },
//      添加整体外部网络对app自己的Code判断 不添加返回整体数据 根据业务需求自行写逻辑
//      onClientCodeJudgeCallBack: (Response object) {
//    String code = object.data['code'];
//    String msg = object.data['msg'];
//    if (code != "00000") {
//      return RMError(rmErrorType: RMErrorType.CLIENT, msg: msg);
//    }
//    return null;
//  }
//  ,customOptions: options // 可以自定义添加options参数
//  ,headsMap: {"":""}
//  ,isShowLog: true
//  ,isOpenCook: true

        );

//  可以链式调用里边的参数
//  httpUtilRM..setHeadsMap ={"ver":"444"} ..setIsShowLog=true;

//  可以添加自定义的拦截器
//    httpUtilRM.setAddInterceptors = (RmLogInterceptor(
//        responseBody: true,
//        request: true,
//        requestHeader: true,
//        responseHeader: true)); //开启请求日志

  }
}
```

[其它具体使用请查看demo](https://github.com/xieyang0727/flutterHttpDemo) 


