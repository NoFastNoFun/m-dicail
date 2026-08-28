enum PathologySource {
  builtIn,
  user,
  pubmed,
}

extension PathologySourceX on PathologySource {
  String get jsonValue {
    switch (this) {
      case PathologySource.builtIn:
        return 'built_in';
      case PathologySource.user:
        return 'user';
      case PathologySource.pubmed:
        return 'pubmed';
    }
  }

  static PathologySource fromJson(String? value) {
    switch (value) {
      case 'built_in':
        return PathologySource.builtIn;
      case 'pubmed':
        return PathologySource.pubmed;
      default:
        return PathologySource.user;
    }
  }
}
