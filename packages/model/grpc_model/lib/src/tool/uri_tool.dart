extension UriX on Uri {
  bool get ssl => ['https', 'wss'].contains(scheme);
}
