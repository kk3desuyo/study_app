// lib/widgets/user/follow_button.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';

class FollowButton extends StatefulWidget {
  final String followingUserId;
  final Function() onChanged;

  FollowButton({
    Key? key,
    required this.followingUserId,
    this.onChanged = _defaultOnChanged,
  }) : super(key: key);

  static void _defaultOnChanged() {}

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isUserFollowing = false;
  bool isUserFollowedByTarget = false;
  bool isBlocked = false; // 新しい状態変数
  String requestStatus = 'no_request';
  final UserService userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId;
  StreamSubscription<DocumentSnapshot>? _followersSubscription;
  StreamSubscription<DocumentSnapshot>? _sentRequestSubscription;
  StreamSubscription<DocumentSnapshot>? _receivedRequestSubscription;
  StreamSubscription<DocumentSnapshot>? _followedByTargetSubscription;
  StreamSubscription<DocumentSnapshot>? _blockedUserSubscription; // 新しいリスナー

  @override
  void initState() {
    super.initState();
    _initializeFollowStatus();
  }

  @override
  void dispose() {
    _followersSubscription?.cancel();
    _sentRequestSubscription?.cancel();
    _receivedRequestSubscription?.cancel();
    _followedByTargetSubscription?.cancel();
    _blockedUserSubscription?.cancel(); // 新しいリスナーのキャンセル
    super.dispose();
  }

  /// 初期フォロー状態の取得
  Future<void> _initializeFollowStatus() async {
    currentUserId = userService.getCurrentUserId();
    print('Current user ID: $currentUserId');
    if (currentUserId != null) {
      _listenToFollowers();
      _listenToSentFollowRequest();
      _listenToReceivedFollowRequest();
      _listenToTargetUserFollowingMe();
      _listenToBlockedStatus(); // 新しいリスナーの追加
    }
  }

  /// ブロック状態のリスナー
  void _listenToBlockedStatus() {
    _blockedUserSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(widget.followingUserId)
        .snapshots()
        .listen((doc) {
      bool blocked = doc.exists;
      print('Blocked Status Listener: blocked=$blocked');
      setState(() {
        isBlocked = blocked;
      });
    }, onError: (error) {
      print('Blocked Status Listener error: $error');
    });
  }

  /// フォロワーのリスナー
  void _listenToFollowers() {
    _followersSubscription = _firestore
        .collection('users')
        .doc(widget.followingUserId)
        .collection('followers')
        .doc(currentUserId)
        .snapshots()
        .listen((doc) {
      bool following = doc.exists;
      print('Followers Listener: following=$following');
      setState(() {
        isUserFollowing = following;
      });
    }, onError: (error) {
      print('Followers Listener error: $error');
    });
  }

  /// 送信したフォローリクエストのリスナー
  void _listenToSentFollowRequest() {
    _sentRequestSubscription = _firestore
        .collection('followRequests')
        .doc('${currentUserId}_${widget.followingUserId}')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        print('Sent Request Listener: requested_by_current_user');
        setState(() {
          requestStatus = 'requested_by_current_user';
        });
      } else {
        print('Sent Request Listener: no_request');
        setState(() {
          requestStatus = 'no_request';
        });
      }
    }, onError: (error) {
      print('Sent Request Listener error: $error');
    });
  }

  /// 受信したフォローリクエストのリスナー
  void _listenToReceivedFollowRequest() {
    _receivedRequestSubscription = _firestore
        .collection('followRequests')
        .doc('${widget.followingUserId}_${currentUserId}')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        print('Received Request Listener: requested_by_target_user');
        setState(() {
          requestStatus = 'requested_by_target_user';
        });
      } else {
        if (requestStatus == 'requested_by_target_user') {
          print('Received Request Listener: no_request');
          setState(() {
            requestStatus = 'no_request';
          });
        }
      }
    }, onError: (error) {
      print('Received Request Listener error: $error');
    });
  }

  /// ターゲットユーザーが現在のユーザーをフォローしているかのリスナー
  void _listenToTargetUserFollowingMe() {
    _followedByTargetSubscription = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('followers')
        .doc(widget.followingUserId)
        .snapshots()
        .listen((doc) {
      bool followed = doc.exists;
      print('Target user following me: $followed');
      setState(() {
        isUserFollowedByTarget = followed;
      });
    }, onError: (error) {
      print('FollowedByTarget Listener error: $error');
    });
  }

  /// フォロー/アンフォローボタンの切り替え
  void _toggleFollow() async {
    if (currentUserId == null) {
      // ユーザーがログインしていない場合、エラーのみ表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインしてください。')),
      );
      return;
    }

    if (isBlocked) {
      // ブロックされている場合は何もしない
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('このユーザーはブロックされています。')),
      );
      return;
    }

    try {
      if (isUserFollowing) {
        // フォロー解除
        print("フォロー解除");
        await userService.updateFollowStatus(widget.followingUserId, false);
      } else if (requestStatus == 'requested_by_target_user') {
        // フォローリクエストを承認
        print("リクエストを承認");
        await userService.approveFollowRequest(widget.followingUserId);
      } else if (isUserFollowedByTarget) {
        // フォローバック
        print("フォローバック");
        await userService.sendFollowRequest(widget.followingUserId);
      } else if (requestStatus == 'requested_by_current_user') {
        // フォローリクエストをキャンセル
        print("フォローリクエストをキャンセル");
        await userService.cancelFollowRequest(widget.followingUserId);
      } else {
        // フォローリクエストを送信
        print("フォローリクエストを送信します。");
        await userService.sendFollowRequest(widget.followingUserId);
        print("フォローリクエストを送信しました。");
      }
      widget.onChanged();
    } catch (e) {
      print('Error toggling follow: $e');
      // エラー時のみSnackbarを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('フォロー操作に失敗しました。')),
      );
    }
  }

  Future<void> _unblockUser(String targetUserId, String userName) async {
    try {
      await userService.unblockUser(targetUserId);
      await _initializeFollowStatus(); // データを再取得してUIを更新
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザーのブロックを解除しました')),
      );
    } catch (e) {
      print('Error unblocking user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ブロック解除に失敗しました')),
      );
    }
  }

  Future<void> _confirmUnblockUser() async {
    try {
      User? user = await userService.getUser(widget.followingUserId);
      String userName = user?.name ?? 'このユーザー';

      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ブロック解除'),
            content: Text('$userName のブロックを解除しますか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('解除', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        _unblockUser(widget.followingUserId, userName);
      }
    } catch (e) {
      print('Error fetching user data for unblock confirmation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ブロック解除の確認に失敗しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building FollowButton: isUserFollowing=$isUserFollowing, isUserFollowedByTarget=$isUserFollowedByTarget, requestStatus=$requestStatus, isBlocked=$isBlocked');

    // 自分自身をフォローしようとした場合、ボタンを非表示
    if (currentUserId == widget.followingUserId) {
      return SizedBox.shrink();
    }

    String buttonText;
    Color backgroundColor;
    Color textColor;

    if (isBlocked) {
      buttonText = 'ブロック解除';
      backgroundColor = Colors.red;
      textColor = Colors.white;
    } else if (isUserFollowing) {
      buttonText = 'フォロー中';
      backgroundColor = Colors.white;
      textColor = subTheme;
    } else if (requestStatus == 'requested_by_target_user') {
      buttonText = 'リクエストを承認';
      backgroundColor = subTheme;
      textColor = Colors.white;
    } else if (requestStatus == 'requested_by_current_user') {
      buttonText = 'フォローリクエスト中';
      backgroundColor = Colors.white;
      textColor = subTheme;
    } else if (isUserFollowedByTarget) {
      buttonText = 'フォローバック';
      backgroundColor = subTheme;
      textColor = Colors.white;
    } else {
      buttonText = 'フォロー';
      backgroundColor = subTheme;
      textColor = Colors.white;
    }

    return SizedBox(
      width: 130, // ボタンの幅を設定
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: isBlocked ? Colors.red : subTheme),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: isBlocked
            ? _confirmUnblockUser
            : _toggleFollow, // ブロック中は確認画面を経てブロック解除
        child: Text(
          buttonText,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
