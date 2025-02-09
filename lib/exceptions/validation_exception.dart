import 'package:flutter/material.dart';

import '../utils/func_utils.dart';
import '../utils/main_utils.dart';
import '../widgets/error_dialog.dart';
import 'ui_exception.dart';

class ValidationException implements UiException {
  final String message;
  final Map<dynamic, dynamic>? fields;

  ValidationException({this.message = 'Some fields have an invalid value', this.fields}) : super();

  @override
  String toString() => message;

  String breakMap() {
    return fields?.values.map((dynamic e) => (e as List).join('\n')).join('\n') ?? '';
  }

  @override
  Future<void> callDialog({
    ErrorCallback? onError,
    VoidCallback? onRetry,
    VoidCallback? onSuccess,
  }) async {
    var willShowDialog = true;
    if (onError != null) {
      willShowDialog = onError(this);
    }

    if (willShowDialog) {
      await showDialog<void>(
        context: appContext!,
        builder: (context) => ErrorDialog(
            errorMessage: 'Alguns campos contém valores inválidos\n'
                'Reveja os valores fornecidos e tente novamente\n'
                '${breakMap()}\n',
            onOk: onSuccess),
        barrierDismissible: false,
      );
    }
  }
}
