import 'package:wanikani_app/core/error/ierror.dart';

class InternalErrorEntity implements IError {
  final String _message;

  InternalErrorEntity(this._message);

  @override
  String get message => _message;
}
