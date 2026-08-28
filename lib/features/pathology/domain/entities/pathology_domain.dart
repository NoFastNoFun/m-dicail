enum PathologyDomain {
  musculoskeletal,
  neurology,
  cardioRespiratory,
  geriatrics,
  pediatrics,
  other,
}

extension PathologyDomainX on PathologyDomain {
  String get jsonValue {
    switch (this) {
      case PathologyDomain.musculoskeletal:
        return 'musculoskeletal';
      case PathologyDomain.neurology:
        return 'neurology';
      case PathologyDomain.cardioRespiratory:
        return 'cardio_respiratory';
      case PathologyDomain.geriatrics:
        return 'geriatrics';
      case PathologyDomain.pediatrics:
        return 'pediatrics';
      case PathologyDomain.other:
        return 'other';
    }
  }

  static PathologyDomain fromJson(String? value) {
    switch (value) {
      case 'musculoskeletal':
        return PathologyDomain.musculoskeletal;
      case 'neurology':
        return PathologyDomain.neurology;
      case 'cardio_respiratory':
        return PathologyDomain.cardioRespiratory;
      case 'geriatrics':
        return PathologyDomain.geriatrics;
      case 'pediatrics':
        return PathologyDomain.pediatrics;
      default:
        return PathologyDomain.other;
    }
  }
}
