import 'package:flutter/material.dart';
import 'package:study_app/screens/home.dart';

enum TabItem {
  home(
    title: 'ホーム',
    icon: Icons.home,
    page: HomeScreen(),
  ),

  report(
    title: 'レポート',
    icon: Icons.stacked_bar_chart,
    page: HomeScreen(),
  ),

  notifyCation(
    title: '通知',
    icon: Icons.notifications,
    page: HomeScreen(),
  ),
  acconut(
    title: 'アカウント',
    icon: Icons.person,
    page: HomeScreen(),
  );

  const TabItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  /// タイトル
  final String title;

  /// アイコン
  final IconData icon;

  /// 画面
  final Widget page;
}
