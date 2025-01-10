import 'package:flutter/material.dart';
import 'package:study_app/theme/color.dart';

class TagSelectionScreen extends StatefulWidget {
  final int tagNumber;
  final List<Map<String, dynamic>> categories;
  final Function(int, Map<String, dynamic>) onTagSelected;

  TagSelectionScreen({
    required this.tagNumber,
    required this.categories,
    required this.onTagSelected,
  });

  @override
  _TagSelectionScreenState createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  bool showingCategories = true;
  Map<String, dynamic>? selectedCategory;
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredTags = [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onCategorySelected(Map<String, dynamic> category) {
    setState(() {
      showingCategories = false;
      selectedCategory = category;
      if (category['categoryName'] == '大学受験') {
        filteredTags = List.from(category['tags']);
        searchController.addListener(_filterTags);
      } else {
        filteredTags = category['tags'];
      }
    });
  }

  void _filterTags() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTags = selectedCategory!['tags'].where((tag) {
        String tagName = tag['name'].toLowerCase();
        return tagName.contains(query);
      }).toList();
    });
  }

  Widget buildCategoryList() {
    return Scaffold(
      appBar: AppBar(
        title: Text('カテゴリーを選択'),
        backgroundColor: subTheme,
      ),
      body: ListView.builder(
        itemCount: widget.categories.length,
        itemBuilder: (BuildContext context, int index) {
          var category = widget.categories[index];
          return ListTile(
            leading: Icon(Icons.category, color: subTheme), // アイコンを追加
            title: Text(
              category['categoryName'],
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              onCategorySelected(category); // カテゴリー選択処理
            },
          );
        },
      ),
    );
  }

  Widget buildTagList() {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory!['categoryName']),
        backgroundColor: subTheme,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              showingCategories = true; // カテゴリー一覧に戻る
              searchController.removeListener(_filterTags);
              searchController.clear();
            });
          },
        ),
      ),
      body: Column(
        children: [
          if (selectedCategory!['categoryName'] == '大学受験')
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '大学名検索',
                  prefixIcon: Icon(Icons.search, color: subTheme),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: subTheme),
                    onPressed: () {
                      searchController.clear();
                      _filterTags();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTags.length,
              itemBuilder: (BuildContext context, int index) {
                var tag = filteredTags[index];
                return ListTile(
                  leading: Icon(Icons.label, color: subTheme), // アイコンを追加
                  title: Text(
                    tag['name'],
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.pop(context); // 画面を閉じる
                    widget.onTagSelected(widget.tagNumber, tag); // タグ選択処理
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showingCategories ? buildCategoryList() : buildTagList();
  }
}
