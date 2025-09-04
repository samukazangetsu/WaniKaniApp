import 'package:wanikani_app/core/error/ierror.dart';

class ApiErrorEntity implements IError {
  final String _message;
  final int? statusCode;

  ApiErrorEntity(this._message, {this.statusCode});

  factory ApiErrorEntity.fromJson(Map<String, dynamic> json) =>
      ApiErrorEntity(
        json['message'] ?? json['error'] ?? 'Erro desconhecido',
        statusCode: json['status_code'],
      );

  @override
  String get message => _message;
}
