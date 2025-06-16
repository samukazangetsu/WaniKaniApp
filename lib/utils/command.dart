import 'package:flutter/material.dart';
import 'package:wanikani_app/utils/result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Result<T>? _result;

  bool get isError => _result is Error;

  bool get isCompleted => _result is Ok;

  Result<T>? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async {
    await _execute(_action);
  }
}

class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
