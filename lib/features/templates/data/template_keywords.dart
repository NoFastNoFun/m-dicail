abstract final class TemplateKeywords {
  static const Map<String, List<String>> byTemplateId = {
    'template_lombalgie_commune': [
      'lombalgie',
      'lombaire',
      'dos',
      'rachis',
      'lombes',
    ],
    'template_entorse_cheville': [
      'entorse',
      'cheville',
      'ottawa',
      'inversion',
      'foulure',
    ],
    'template_cervicalgie_chronique': [
      'cervicalgie',
      'cervical',
      'nuque',
      'trapeze',
      'cervicales',
    ],
    'template_tendinopathie_achille': [
      'achille',
      'tendinite',
      'tendinopathie',
      'talon',
      'tendon achille',
    ],
    'template_post_op_lca': [
      'lca',
      'croise',
      'ligament croise',
      'genou oper',
      'rupture lca',
      'ligament croise anterieur',
    ],
    'template_capsulite_retractile': [
      'capsulite',
      'epaule gelee',
      'epaule',
      'coiffe',
      'epaule droite',
      'epaule gauche',
    ],
    'template_syndrome_patello_femoral': [
      'patella',
      'rotulien',
      'rotule',
      'genou coureur',
      'patello',
      'femoro-patellaire',
    ],
    'template_epicondylite_laterale': [
      'epicondylite',
      'tennis elbow',
      'coude',
      'mills',
      'cozen',
    ],
    'template_post_op_pth': [
      'prothese hanche',
      'pth',
      'hanche oper',
      'prothese totale hanche',
      'hanche',
    ],
    'template_sciatalgie_radiculopathie': [
      'sciatalgie',
      'sciatique',
      'lasegue',
      'radiculopathie',
      'cruralgie',
      'hernie',
    ],
  };

  static List<String> forTemplate(String templateId) {
    return byTemplateId[templateId] ?? const [];
  }
}
