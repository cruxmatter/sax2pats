class IPCClassificationFactory < EntityFactory
  def entity_class
    IPCClassification
  end

  def ipc_classification
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::IPCClassificationVersion
  end

  def attribute_keys
    %w[
      version_date
      classification_level
      section
      cclass
      subclass
      main_group
      subgroup
      symbol_position
      action_date
      generating_office_country
      classification_status
      classification_data_source
    ]
  end
end
