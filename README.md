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

## 内部文件

1.flutter_package_http_rm.dart   所有对Dio封装方法

2.http_rm_configuration.dart 配置文件 (baseUrl,是否打印日志,是否保留cook,http的heads)

## 使用方法

### 外部可选配置
```bash
HTTP_RM_CONFIGURATION.baseHttpURL="http://*****"; (必填)

HTTP_RM_CONFIGURATION.isHttpOpenLog=true; (不填写默认false)

HTTP_RM_CONFIGURATION.isHttpOpenCook=true(不填写默认false);

HTTP_RM_CONFIGURATION.headsMap ={
      "version": "1.0.0"
    };
```
方法调用
```bash 
void setUpHttp () async{

//下列回调可选填也可不填

HttpUtilRM httpUtilRM =HttpUtilRM(onRequestBefore:(){

  print('开始网络请求了');

},onRequestErrorBefore: (){

  print('将要出错误了');

},onResponseBefore: (){

  print('网络响应之前');

},parameterErrorCallbackRM: (DioError e){

  print('网络出错误了回调 $e');

});

  ResponseData responsePost = await httpUtilRM.post(Api.TEST_LIST2);

  Response response =responsePost.response;

  print('responsePost $response');

}
```

[其它具体使用请查看demo](https://github.com/xieyang0727/flutterHttpDemo) 


