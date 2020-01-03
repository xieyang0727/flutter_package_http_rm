import 'package:dio/dio.dart';

enum RMErrorType {
  CLIENT,
  NET,
  DEFAULT,
}

class RMError {
  String msg;
  DioError dioError;
  RMErrorType rmErrorType;

  RMError({
    this.msg,
    this.dioError,
    this.rmErrorType = RMErrorType.DEFAULT,
  });
}
