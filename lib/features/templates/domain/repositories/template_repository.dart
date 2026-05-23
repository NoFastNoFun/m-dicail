import 'package:medicail/features/templates/domain/entities/custom_template_variant.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';

abstract class TemplateRepository {
  Future<void> ensureSeeded();

  Future<List<SoapTemplate>> getBuiltinTemplates({String? query});

  Future<List<CustomTemplateVariant>> getVariants({String? query});

  Future<List<TemplateListItem>> getAllItems({String? query});

  Future<CustomTemplateVariant?> findVariantByDisplayName(String displayName);

  Future<void> saveVariant(CustomTemplateVariant variant);
}
