extension ExceptionMessage on Object {
  String cleanError() => toString().replaceFirst('Exception: ', '');
}
