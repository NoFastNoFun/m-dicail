class DuplicateTemplateVariantNameException implements Exception {
  const DuplicateTemplateVariantNameException(this.existingVariantId);

  final String existingVariantId;
}
