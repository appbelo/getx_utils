import 'package:dio/dio.dart';
import 'package:ferry/typed_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:universal_io/io.dart';

import '../exceptions/account_deletation_in_progress.dart';
import '../exceptions/auth_exception.dart';
import '../exceptions/auth_wrong_exception.dart';
import '../exceptions/generic_error_exception.dart';
import '../exceptions/graphql_error_exception.dart';
import '../exceptions/outdated_client_exception.dart';
import '../exceptions/payment_refused_exception.dart';
import '../exceptions/permission_exception.dart';
import '../exceptions/register_must_verify_email_exception.dart';
import '../exceptions/server_error_exception.dart';
import '../exceptions/validation_exception.dart';
import '../widgets/error_dialog.dart';
import 'main_utils.dart';

Future<T> runFutureWithErrorDialog<T>(
    {required Future<T> Function() callback,
    required VoidCallback onError,
    ProgressDialog? dialog,
    VoidCallback? onRetry,
    VoidCallback? onSuccess}) async {
  try {
    return await callback();
  } on GraphQLErrorException catch (e) {
    try {
      throw rethrowAuth(e);
    } catch (e) {
      dialog?.dismiss();
      displayErrorDialog(e, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
      rethrow;
    }
  } catch (e) {
    dialog?.dismiss();
    displayErrorDialog(e, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
    rethrow;
  }
}

Exception rethrowAuth(GraphQLErrorException exception) {
  if (exception.errors != null) {
    for (final error in exception.errors!) {
      switch (error.message) {
        case 'Unauthenticated.':
        case 'Not Authenticated':
          return AuthException();
        case 'invalid_grant':
          return AuthWrongException();
        case 'Outdated Client':
          return OutdatedClientException();
        case 'This action is unauthorized.':
          return PermissionException();
        case 'PAYMENT_REFUSED':
          return PaymentRefusedException(
            code: error.extensions?['code'] as String?,
            reason: error.extensions?['reason'] as String?,
            operation: error.extensions?['operation'] as String?,
          );
        case 'Account Terminated.':
          return AccountDeletationInProgressException();
        case 'Internal server error':
          return ServerErrorException();
        case 'Generic Error':
          return GenericErrorException(
            code: error.extensions?['code'] as String?,
            reason: error.extensions?['reason'] as String?,
            operation: error.extensions?['operation'] as String?,
          );
        default:
          if (error.message.contains('Validation failed')) {
            return ValidationException(fields: error.extensions?['validation'] as Map?);
          } else {
            return Exception('Unknown Error');
          }
      }
    }
  }

  if (exception.linkException != null) {
    if (exception.linkException is ServerException && exception.linkException!.originalException is DioError) {
      return exception.linkException!.originalException! as DioError;
    } else if (exception.linkException is ServerException && exception.linkException!.originalException is Exception) {
      return exception.linkException!.originalException! as Exception;
    } else if (exception.linkException is LinkException && exception.linkException!.originalException is DioError) {
      return exception.linkException!.originalException! as DioError;
    } else if (exception.linkException is LinkException && exception.linkException!.originalException is Exception) {
      return exception.linkException!.originalException! as Exception;
    } else {
      return exception;
    }
  }

  return Exception('Unknown Error');
}

void displayErrorDialog(dynamic error, {required Function onError, VoidCallback? onRetry, VoidCallback? onSuccess}) {
  if (error is AuthException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is PermissionException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is AuthWrongException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is RegisterMustVerifyEmailException) {
    error.callDialog(onSuccess: onSuccess).whenComplete(() => onSuccess ?? () {});
  } else if (error is OutdatedClientException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is ValidationException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is PaymentRefusedException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is AccountDeletationInProgressException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is ServerErrorException) {
    error.callDialog(onRetry: onRetry, onSuccess: onSuccess).whenComplete(() => onError);
  } else if (error is GraphQLErrorException) {
    var r = rethrowAuth(error);
    return displayErrorDialog(r, onError: onError, onRetry: onRetry, onSuccess: onSuccess);
  } else if (error is DioError) {
    if (error.type == DioErrorType.connectTimeout ||
        error.type == DioErrorType.receiveTimeout ||
        error.type == DioErrorType.sendTimeout) {
      showDialog<void>(
        context: appContext!,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao executar a ação\n'
                'Tempo esgotado aguardando resposta do servidor\n'
                'Verifique sua conexão com a internet e tente novamente.\n'
                'Caso o problema persista e não seja sua internet, entre em contato com o suporte.\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.type == DioErrorType.other) {
      showDialog<void>(
        context: appContext!,
        builder: (context) => ErrorDialog(
            errorMessage: 'Falha ao conectar ao Servidor\n'
                'Verifique sua conexão com a internet e tente novamente\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else if (error.response == null) {
      showDialog<void>(
        context: appContext!,
        builder: (context) => ErrorDialog(
            errorMessage: 'O Servidor não enviou uma resposta\n'
                'Verifique sua conexão com a internet e tente novamente\n',
            onRetry: onRetry),
        barrierDismissible: false,
      ).whenComplete(() => onError);
    } else {
      if (error.response?.statusCode == null) {
        showDialog<void>(
          context: appContext!,
          builder: (context) => ErrorDialog(
              errorMessage: 'Erro desconhecido na conexão com o servidor\n'
                  'Verifique sua conexão com a internet e tente novamente\n'
                  'Detalhes do Erro: Código de Estado HTTP está Nulo \n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 460) {
        showDialog<void>(
          context: appContext!,
          builder: (context) => ErrorDialog(
              errorMessage: 'Este aplicativo está desatualizado\n'
                  'Por favor faça uma atualização na loja de aplicativos de seu dispositivo\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response?.statusCode == 429) {
        showDialog<void>(
          context: appContext!,
          builder: (context) => ErrorDialog(
              errorMessage: 'Você fez várias requisições em um curto periodo de tempo\n'
                  'Muitas tentativas de conexão, tente mais tarde\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else if (error.response!.statusCode! >= 500 || error.response!.statusCode! <= 599) {
        showDialog<void>(
          context: appContext!,
          builder: (context) => ErrorDialog(
              errorMessage: 'Falha no servidor\n'
                  'Ocorreu um problema no nosso sistema\n'
                  'Aguarde um pouco e tente novamente\n'
                  'Caso o problema persista entre em contato com o suporte.\n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      } else {
        showDialog<void>(
          context: appContext!,
          builder: (context) => ErrorDialog(
              errorMessage: 'Erro desconhecido na conexão com o servidor\n'
                  'Verifique sua conexão com a internet e tente novamente\n'
                  'Detalhes do Erro $error \n',
              onRetry: onRetry),
          barrierDismissible: false,
        ).whenComplete(() => onError);
      }
    }
  } else if (error is SocketException) {
    showDialog<void>(
      context: appContext!,
      builder: (context) => ErrorDialog(
          errorMessage: 'Falha ao conectar-se ao servidor\n'
              'Verifique sua conexão com a internet e tente novamente\n',
          onRetry: onRetry),
      barrierDismissible: false,
    ).whenComplete(() => onError);
  } else {
    showDialog<void>(
      context: appContext!,
      builder: (context) => ErrorDialog(
          errorMessage: 'Falha ao executar a ação\n'
              'Erro: $error\n',
          onRetry: onRetry),
      barrierDismissible: false,
    ).whenComplete(() => onError);
  }
}
