import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/models/event.dart';
import 'package:study_app/services/user/user_service.dart';

class EventService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Streamでイベントデータを取得
  Stream<Event?> getUserEventStream() {
    final userService = UserService();
    final userId = userService.getCurrentUserId();
    return usersCollection
        .doc(userId)
        .collection('event') // ユーザーごとのイベントコレクションを参照
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first; // 最初のイベントを取得
        return Event.fromDocument(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    });
  }

  // Firestoreにイベントを追加または更新する関数
  Future<void> addOrUpdateEvent(Event event) async {
    final userService = UserService();
    final userId = userService.getCurrentUserId();

    try {
      // イベントがすでに存在するか確認
      final eventSnapshot = await usersCollection
          .doc(userId)
          .collection('event')
          .limit(1) // イベントが1つでも存在するか確認
          .get();

      if (eventSnapshot.docs.isNotEmpty) {
        // すでに存在する場合は更新
        final existingEventId = eventSnapshot.docs.first.id;
        await usersCollection
            .doc(userId)
            .collection('event')
            .doc(existingEventId)
            .update(event.toMap());
        print('Event updated successfully!');
      } else {
        // 存在しない場合は新規追加
        await usersCollection
            .doc(userId)
            .collection('event')
            .add(event.toMap());
        print('Event added successfully!');
      }
    } catch (e) {
      print('Failed to add or update event: $e');
      throw Exception('Failed to add or update event');
    }
  }
}
