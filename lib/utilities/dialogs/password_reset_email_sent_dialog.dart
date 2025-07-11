import 'package:flutter/material.dart';
import 'package:successnotes/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
        'We have sent you a password reset link. Please check your email for more informmation.',
    optionsBuilder: () => {'OK': null},
  );
}
