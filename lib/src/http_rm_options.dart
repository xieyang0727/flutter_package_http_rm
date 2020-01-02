import 'package:dio/dio.dart';
import 'http_rm_configuration.dart';
class OptionsRM {
  returnOption(Map<String, dynamic> headsMap) {
    const bool inProduction =
    const bool.fromEnvironment("dart.vm.product"); //判断是否release还是debug环境

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

    Map<String, dynamic> heads = HTTP_RM_CONFIGURATION.headsMap;
    if (headsMap != null) {
      heads = headsMap;
    }

    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    return BaseOptions(
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
  }
}
