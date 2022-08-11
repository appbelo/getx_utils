import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/func_utils.dart';
import '../widgets/warning_dialog.dart';
import 'ui_exception.dart';

class RegisterMustVerifyEmailException implements UiException {
  final String message;

  RegisterMustVerifyEmailException({this.message = 'Please check you email to continue registration'}) : super();

  @override
  String toString() => message;

  @override
  Future<void> callDialog({
    ErrorCallback? onError,
    VoidCallback? onRetry,
    VoidCallback? onSuccess,
  }) async {
    var showDialog = true;
    if (onError != null) {
      showDialog = onError(this);
    }

    if (showDialog) {
      await Get.dialog<void>(
        WarningDialog(
            errorMessage: 'Registro efetuado com sucesso\n'
                'Por favor verifique seu email para ativar sua conta\n',
            onOk: onSuccess),
        barrierDismissible: false,
      );
    }
  }
}
