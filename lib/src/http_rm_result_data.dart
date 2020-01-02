
import 'package:dio/dio.dart';

//整体返回的数据
class ResponseDataRM {

  Response response; // 返回正常的数据
  bool isSuccess = false; //是否请求数据成功
  DioError dioError; // 错误的信息
  String url = "";

  ResponseDataRM(this.isSuccess, {this.url = "",this.response,this.dioError});

}



