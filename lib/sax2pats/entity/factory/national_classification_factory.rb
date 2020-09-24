class NationalClassificationFactory < EntityFactory
  def entity_class
    NationalClassification
  end

  def national_classification
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::NationalClassificationVersion
  end

  def attribute_keys
    %w[
      country
      main_classification
      further_classification
    ]
  end
end
