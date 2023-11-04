// ignore_for_file: avoid_classes_with_only_static_members

class Validators {
  static final _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final _passwordRegExp = RegExp(
    r'^.{5,}$',
  );

  static bool isValidName(String? name) => name != null && name.length > 1;

  static bool isValidEmail(String? email) {
    if (email == null) return false;

    return _emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String? password) {
    if (password == null) return false;

    return _passwordRegExp.hasMatch(password);
  }
}
