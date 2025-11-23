// Widget tests for Math Kids App
//
// Tests to verify the app functionality and UI components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appmath/main.dart';

void main() {
  group('Math Kids App Tests', () {
    testWidgets('App loads and shows splash screen', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const MathKidsApp());

      // Verify splash screen elements
      expect(find.text('กระต่ายน้อย'), findsOneWidget);
      expect(find.text('สอนคณิตศาสตร์'), findsOneWidget);
      expect(find.text('✨ สนุกกับการเรียนรู้ ✨'), findsOneWidget);
    });

    testWidgets('Splash screen navigates to auth screen', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const MathKidsApp());

      // Wait for splash screen animation (3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify we're on auth screen
      expect(find.text('สวัสดี! 👋'), findsOneWidget);
      expect(find.text('มาเรียนคณิตกับกระต่ายกันเถอะ'), findsOneWidget);
      expect(find.text('🥕 สมัครสมาชิก'), findsOneWidget);
      expect(find.text('🐇 เข้าสู่ระบบ'), findsOneWidget);
    });

    testWidgets('Login button navigates to login screen', (
      WidgetTester tester,
    ) async {
      // Build the app and wait for auth screen
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Tap login button
      await tester.tap(find.text('🐇 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('ยินดีต้อนรับกลับมา! 🎉'), findsOneWidget);
      expect(find.text('👤 ชื่อผู้ใช้'), findsOneWidget);
      expect(find.text('🔒 รหัสผ่าน'), findsOneWidget);
      expect(find.text('🐰 เข้าสู่ระบบ'), findsOneWidget);
    });

    testWidgets('Signup button navigates to signup screen', (
      WidgetTester tester,
    ) async {
      // Build the app and wait for auth screen
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Tap signup button
      await tester.tap(find.text('🥕 สมัครสมาชิก'));
      await tester.pumpAndSettle();

      // Verify we're on signup screen
      expect(find.text('สร้างบัญชีใหม่ 🥕'), findsOneWidget);
      expect(find.text('👤 ชื่อผู้ใช้'), findsOneWidget);
      expect(find.text('📱 เบอร์โทรศัพท์'), findsOneWidget);
      expect(find.text('✨ สมัครเลย ✨'), findsOneWidget);
    });

    testWidgets('Can navigate to main menu', (WidgetTester tester) async {
      // Build the app and wait for auth screen
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate through login to main menu
      await tester.tap(find.text('🐇 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('🐰 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      // Verify we're on main menu
      expect(find.text('เมนูหลัก 🏠'), findsOneWidget);
      expect(find.text('📚 เรียนรู้กับกระต่าย'), findsOneWidget);
      expect(find.text('⚙️ การตั้งค่า'), findsOneWidget);
    });

    testWidgets('Can navigate to category screen', (WidgetTester tester) async {
      // Build the app and navigate to main menu
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Go through login flow
      await tester.tap(find.text('🐇 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🐰 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      // Navigate to category screen
      await tester.tap(find.text('📚 เรียนรู้กับกระต่าย'));
      await tester.pumpAndSettle();

      // Verify we're on category screen
      expect(find.text('🐰 หมวดหมู่'), findsOneWidget);
      expect(find.text('การบวกเลข'), findsOneWidget);
      expect(find.text('การลบเลข'), findsOneWidget);
      expect(find.text('การคูณเลข'), findsOneWidget);
      expect(find.text('การหารเลข'), findsOneWidget);
      expect(find.text('รูปเรขาคณิต'), findsOneWidget);
    });

    testWidgets('Settings screen has sound and music toggles', (
      WidgetTester tester,
    ) async {
      // Build the app and navigate to settings
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate through login to main menu
      await tester.tap(find.text('🐇 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🐰 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      // Go to settings
      await tester.tap(find.text('⚙️ การตั้งค่า'));
      await tester.pumpAndSettle();

      // Verify settings screen
      expect(find.text('🐰 การตั้งค่า'), findsOneWidget);
      expect(find.text('🔊 เสียงประกอบ'), findsOneWidget);
      expect(find.text('🎵 เพลง'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('Back button works on login screen', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const MathKidsApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Navigate to login screen
      await tester.tap(find.text('🐇 เข้าสู่ระบบ'));
      await tester.pumpAndSettle();

      // Verify we're on login screen
      expect(find.text('ยินดีต้อนรับกลับมา! 🎉'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // Verify we're back on auth screen
      expect(find.text('สวัสดี! 👋'), findsOneWidget);
    });
  });
}
