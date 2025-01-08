import 'package:career_guild/main.dart';
import 'package:career_guild/pages/login_page.dart';
import 'package:career_guild/pages/profile_page.dart' as profile;
import 'package:career_guild/auth/auth.dart';
import 'package:career_guild/pages/users_page.dart' as users;
import 'package:career_guild/components/my_drawer.dart'; // Add the import for MyDrawer
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock FirebaseAuth for testing sign out functionality
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('Check if AuthPage is displayed initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('Navigation to ProfilePage works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final BuildContext context = tester.element(find.byType(AuthPage));
    Navigator.of(context).pushNamed('/profile_page');
    await tester.pumpAndSettle();
    expect(find.byType(profile.ProfilePage), findsOneWidget);
  });

  testWidgets('Navigation to UsersPage works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final BuildContext context = tester.element(find.byType(AuthPage));
    Navigator.of(context).pushNamed('/users_page');
    await tester.pumpAndSettle();
    expect(find.byType(users.UsersPage), findsOneWidget);
  });

  testWidgets('Verify LoginPage has login functionality',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage(onTap: () {})));
    await tester.enterText(
        find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('Check if UsersPage displays a list of users',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const users.UsersPage()));
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('User 1'), findsWidgets); // Adjust based on your test data
  });

  // Test for MyDrawer widget
  testWidgets('Verify if MyDrawer has navigation functionality',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        drawer: const MyDrawer(),
        body: Center(child: Text('Home Page')),
      ),
    ));

    // Open the drawer
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // Verify the presence of navigation options
    expect(find.text('H O M E'), findsOneWidget);
    expect(find.text('P R O F I L E'), findsOneWidget);
    expect(find.text('U S E R S'), findsOneWidget);
    expect(find.text('L O G O U T'), findsOneWidget);

    // Test navigation to ProfilePage
    await tester.tap(find.text('P R O F I L E'));
    await tester.pumpAndSettle();
    expect(find.byType(profile.ProfilePage), findsOneWidget);

    // Go back to the previous page
    Navigator.pop(tester.element(find.byType(profile.ProfilePage)));
    await tester.pumpAndSettle();

    // Test navigation to UsersPage
    await tester.tap(find.text('U S E R S'));
    await tester.pumpAndSettle();
    expect(find.byType(users.UsersPage), findsOneWidget);

    // Go back to the previous page
    Navigator.pop(tester.element(find.byType(users.UsersPage)));

    // Test logout functionality (ensure logout is triggered)
    final mockAuth = MockFirebaseAuth();
    when(() => mockAuth.signOut()).thenAnswer((_) async => Future.value());
    await tester.tap(find.text('L O G O U T'));
    await tester.pumpAndSettle();

    // Ensure signOut method was called
    verify(() => mockAuth.signOut()).called(1);
  });
}
