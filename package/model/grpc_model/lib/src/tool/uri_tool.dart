extension UriX<F> on Uri {
  bool get ssl => ['https', 'wss'].contains(scheme);
}
