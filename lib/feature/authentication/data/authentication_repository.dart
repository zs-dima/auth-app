// TODO

// import 'dart:async';
// import 'dart:convert';

// import 'package:auth_app/feature/authentication/model/sign_in_data.dart';
// import 'package:auth_model/auth_model.dart';
// import 'package:auth_app/feature/settings/data/settings_repository.dart';

// abstract interface class IAuthenticationRepository {
//   Stream<User> userChanges();
//   FutureOr<User> getUser();
//   Future<void> signIn(SignInData data);
//   Future<void> restore();
//   Future<void> signOut();
// }

// class AuthenticationRepositoryImpl implements IAuthenticationRepository {
//   static const _sessionKey = 'authentication.session';
//   final ISettingsRepository _settings;
//   final _userController = StreamController<User>.broadcast();
//   User _user = const User.unauthenticated();

//   AuthenticationRepositoryImpl({
//     required ISettingsRepository settings,
//   }) : _settings = settings;

//   @override
//   FutureOr<User> getUser() => _user;

//   @override
//   Stream<User> userChanges() => _userController.stream;

//   @override
//   Future<void> signIn(SignInData data) => Future<void>.delayed(
//         const Duration(seconds: 1),
//         () {
//           final user = User.authenticated(id: data.username);
//           _settings.user = user;
//           _userController.add(_user = user);
//         },
//       );

//   @override
//   Future<void> restore() async {
//     final session = _settings.getString(_sessionKey);
//     if (session == null) return;
//     final json = jsonDecode(session);
//     if (json case final Map<String, Object?> jsonMap) {
//       final user = User.fromJson(jsonMap);
//       _userController.add(_user = user);
//     }
//   }

//   @override
//   Future<void> signOut() => Future<void>.sync(
//         () {
//           const user = User.unauthenticated();
//           _settings.remove(_sessionKey).ignore();
//           _userController.add(_user = user);
//         },
//       );
// }
