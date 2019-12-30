
class HTTP_RM_CONFIGURATION {


//  baseHttpURL(如果配置了baseHttpURL读取配置的如果没有配置，那么根据debug和release自动读取baseReleaseHttpURL和baseDebugHttpURL)
  static String baseHttpURL ="";
  //  baseReleaseHttpURL
  static String baseReleaseHttpURL ="";
  //  baseDebugHttpURL
  static String baseDebugHttpURL ="";

//  是否打开log日志
  static bool isHttpOpenLog = false;
//  是否打开cook
  static bool isHttpOpenCook = false;
//  自定义头
  static Map<String, dynamic> headsMap ;



}

