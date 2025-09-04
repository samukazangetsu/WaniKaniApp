import 'package:flutter/material.dart';

mixin DecodeModelMixin {
  T tryDecode<T>(
    T Function() decodeFunction, {
    required T Function(Object exception) orElse,
  }) {
    try {
      return decodeFunction();
    } catch (exception) {
      FlutterError.reportError(FlutterErrorDetails(exception: exception));
      return orElse(exception);
    }
  }
}
