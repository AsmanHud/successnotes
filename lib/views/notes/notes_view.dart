import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:successnotes/constants/routes.dart';
import 'package:successnotes/enums/menu_action.dart';
import 'package:successnotes/services/auth/auth_service.dart';
import 'package:successnotes/services/auth/bloc/auth_bloc.dart';
import 'package:successnotes/services/auth/bloc/auth_event.dart';
import 'package:successnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:successnotes/utilities/dialogs/logout_dialog.dart';
import 'package:successnotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes View'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    if (context.mounted) {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data!;
                return NotesListView(
                  notes: allNotes,
                  onTap: (note) {
                    Navigator.of(
                      context,
                    ).pushNamed(createOrUpdateNoteRoute, arguments: note);
                  },
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                );
              }
              return const CircularProgressIndicator();
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
