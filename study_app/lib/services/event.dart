import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/user/user_service.dart';

class EventService {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // Streamでイベントデータを取得
  Stream<String> getUserEventNameStream() {
    final userService = UserService();
    final userId = userService.getCurrentUserId();
    return eventsCollection
        .doc(userId) // userIdを直接ドキュメントIDとして参照
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final eventName = snapshot['name'] as String; // イベント名を取得
        print('Event name: $eventName'); // デバッグ用にイベント名を出力
        return eventName;
      } else {
        print('No events found for user: $userId'); // デバッグ用にメッセージを出力
        return '';
      }
    });
  }
}
