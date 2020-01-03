
import 'package:dio/dio.dart';
import 'http_rm_error.dart';
//整体返回的数据
class ResponseDataRM {

  Response response; // 返回正常的数据
  bool isSuccess = false; //是否请求数据成功
  RMError rmError; // 错误的信息
  String url = ""; //调用的url

  ResponseDataRM(this.isSuccess, {this.url = "",this.response,this.rmError});

}



