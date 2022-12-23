import 'package:flutter/material.dart';

void reportUnexpectedError(
  BuildContext context, {
  required Object error,
  StackTrace? stackTrace,
}) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'App',
    ),
  );

  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    const SnackBar(content: Text('An unexpected error occurred.')),
  );
}

Future<void> runActionGuarded(
  BuildContext context,
  Future<void> Function() action, {
  void Function()? onFinally,
}) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    reportUnexpectedError(context, error: error, stackTrace: stackTrace);
  } finally {
    onFinally?.call();
  }
}

class AppTheme {
  static InputDecoration inputDecoration({required String label}) =>
      InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        label: Text(label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
      );
}
