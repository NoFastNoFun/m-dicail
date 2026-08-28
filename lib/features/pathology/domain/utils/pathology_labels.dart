import 'package:medicail/features/pathology/domain/entities/pathology.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';

extension PathologyDomainLabel on PathologyDomain {
  String labelFr() {
    switch (this) {
      case PathologyDomain.musculoskeletal:
        return 'Musculosquelettique';
      case PathologyDomain.neurology:
        return 'Neurologie';
      case PathologyDomain.cardioRespiratory:
        return 'Cardio-respiratoire';
      case PathologyDomain.geriatrics:
        return 'Geriatrie';
      case PathologyDomain.pediatrics:
        return 'Pediatrie';
      case PathologyDomain.other:
        return 'Autre';
    }
  }
}

extension PathologySourceLabel on Pathology {
  String sourceBadgeFr() {
    switch (source) {
      case PathologySource.builtIn:
        return 'Defaut';
      case PathologySource.user:
        return 'Personnalise';
      case PathologySource.pubmed:
        return 'PubMed';
    }
  }
}
