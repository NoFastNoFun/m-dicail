enum NoteTemplateSource {
  builtIn,
  userVariant,
}

extension NoteTemplateSourceX on NoteTemplateSource {
  String get jsonValue => name;

  static NoteTemplateSource fromJson(String? value) {
    return NoteTemplateSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => NoteTemplateSource.userVariant,
    );
  }
}
