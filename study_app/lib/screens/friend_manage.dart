import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_app/services/user/user_service.dart';
import 'package:study_app/theme/color.dart';
import 'package:study_app/widgets/follow_button.dart';
import 'package:study_app/models/user.dart';
import 'package:study_app/screens/other_user_display.dart';

class FriendSerch extends StatefulWidget {
  FriendSerch({Key? key}) : super(key: key);

  @override
  _FriendSerchState createState() => _FriendSerchState();
}

class _FriendSerchState extends State<FriendSerch> {
  final _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> searchResults = [];
  final UserService userService = UserService();
  String currentUserId = '';
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMoreData = true;
  static const int pageSize = 10;
  bool tmp = false;
  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    _fetchFriendOfFriends();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeCurrentUser() async {
    currentUserId = userService.getCurrentUserId()!;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      tmp = !tmp;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMoreData) {
      _fetchMoreResults();
    }
  }

  void _submission(String text) async {
    if (text.isEmpty) {
      _fetchFriendOfFriends();
      return;
    }

    searchResults.clear();
    lastDocument = null;
    hasMoreData = true;

    String searchText = text.toLowerCase();
    await _fetchResults(searchText: searchText);
  }

  Future<void> _fetchResults({String? searchText}) async {
    setState(() => isLoading = true);

    Query query =
        FirebaseFirestore.instance.collection('users').limit(pageSize);
    if (searchText != null) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchText)
          .where('name', isLessThan: searchText + '\uf8ff');
    }
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last;
      for (var doc in querySnapshot.docs) {
        if (doc.id != currentUserId) {
          searchResults.add({
            "isPublic": doc['isPublic'] ?? false,
            "name": doc['name'] ?? 'Unknown',
            "userId": doc.id,
            "profileImgUrl": doc['profileImgUrl'] ?? '',
          });
        }
      }
    } else {
      hasMoreData = false;
    }

    setState(() => isLoading = false);
  }

  Future<void> _fetchFriendOfFriends() async {
    searchResults.clear();
    lastDocument = null;
    hasMoreData = true;

    await _fetchResults();
  }

  void _fetchMoreResults() {
    if (hasMoreData) {
      _fetchResults(
          searchText: _controller.text.isNotEmpty
              ? _controller.text.toLowerCase()
              : null);
    }
  }

  void _navigateToOtherUserDisplay(Map<String, dynamic> userData) {
    final user = User(
      isPublic: userData['isPublic'],
      profileImgUrl: userData['profileImgUrl'],
      name: userData['name'],
      id: userData['userId'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherUserDisplay(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_circle_left_rounded,
            size: 45,
            color: Colors.orange,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "ユーザーを検索",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'ユーザー名、ユーザーIDで検索',
                  prefixIcon: Icon(Icons.search, color: subTheme),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: subTheme),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        FocusScope.of(context).unfocus();
                        _fetchFriendOfFriends();
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                onSubmitted: (text) => _submission(text),
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              _controller.text.isEmpty ? '知り合いかも' : '検索結果',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15.0),
            if (searchResults.isEmpty && _controller.text.isNotEmpty)
              Center(child: Text('検索結果がありません', style: TextStyle(fontSize: 18))),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: searchResults.length + 1,
                itemBuilder: (context, index) {
                  if (index == searchResults.length) {
                    return isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SizedBox.shrink();
                  }
                  final user = searchResults[index];
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () => _navigateToOtherUserDisplay(user),
                      child: CircleAvatar(
                        backgroundImage: user['profileImgUrl'] != ''
                            ? NetworkImage(user['profileImgUrl'])
                            : null,
                        backgroundColor: subTheme,
                        child: user['profileImgUrl'] == ''
                            ? Text(user['name'][0])
                            : null,
                      ),
                    ),
                    title: GestureDetector(
                      onTap: () => _navigateToOtherUserDisplay(user),
                      child: Text(
                        user['name'].length > 7
                            ? '${user['name'].substring(0, 7)}...'
                            : user['name'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: FollowButton(
                      followingUserId: user['userId'],
                      onChanged: _onChanged,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
