import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:successnotes/services/auth/bloc/auth_bloc.dart';
import 'package:successnotes/services/auth/bloc/auth_event.dart';
import 'package:successnotes/services/auth/bloc/auth_state.dart';
import 'package:successnotes/utilities/dialogs/error_dialog.dart';
import 'package:successnotes/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgorPasswordView extends StatefulWidget {
  const ForgorPasswordView({super.key});

  @override
  State<ForgorPasswordView> createState() => _ForgorPasswordViewState();
}

class _ForgorPasswordViewState extends State<ForgorPasswordView> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgorPassword) {
          if (state.hasSentEmail) {
            _textController.clear();
            await showPasswordResetEmailSentDialog(context);
          }
          if (state.exception != null) {
            if (context.mounted) {
              await showErrorDialog(
                context,
                'We could not process your request. Please make sure you are a registered user, or if not, register a user now going back one step.',
              );
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Forgor Password View')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'If you forgor your password, simply enter your email and we will send you a password reset link.',
              ),
              TextField(
                controller: _textController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Your email address...',
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _textController.text;
                  context.read<AuthBloc>().add(
                    AuthEventForgorPassword(email: email),
                  );
                },
                child: const Text('Send me a password reset link'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text('Back to login page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
