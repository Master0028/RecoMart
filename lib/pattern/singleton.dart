class UserSession {
  static final UserSession instance = UserSession._internal();
  UserSession._internal();

  String? userId;

  bool get isLoggedIn => userId != null && userId!.isNotEmpty;

  void setUser(String uid) {
    userId = uid;
  }

  void clear() {
    userId = null;
  }
}
