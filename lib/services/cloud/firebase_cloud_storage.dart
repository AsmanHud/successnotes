import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:successnotes/services/cloud/cloud_note.dart';
import 'package:successnotes/services/cloud/cloud_storage_constants.dart';
import 'package:successnotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  // Get notes collection reference
  final notes = FirebaseFirestore.instance.collection(notesCollectionName);

  /// Returns a stream of all notes for the given user
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map(
        (event) => event.docs
            .map((doc) => CloudNote.fromSnapshot(doc))
            .where((note) => note.ownerUserId == ownerUserId),
      );

  // C in CRUD
  void createNewNote({required String ownerUserId}) async {
    try {
      await notes.add({ownerUserIdFieldName: ownerUserId, textFieldName: ''});
    } catch (e) {
      throw CouldNotCreateNoteException();
    }
  }

  // R in CRUD
  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
          .get()
          .then((value) {
            return value.docs.map((doc) {
              return CloudNote.fromSnapshot(doc);
            });
          });
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // U in CRUD
  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  // D in CRUD
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  // Singleton creation logic
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._();
  FirebaseCloudStorage._();
  factory FirebaseCloudStorage() => _shared;
}
