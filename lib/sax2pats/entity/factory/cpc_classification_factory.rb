class CPCClassificationFactory < EntityFactory
  def initialize(xml_version_adaptor, data_hash, type)
    @type = type
    super(xml_version_adaptor, data_hash)
  end

  def entity_class
    Sax2pats::CPCClassification
  end

  def cpc_classification
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::CPCClassificationVersion
  end

  def attribute_keys
    %w[
      type
      version_date
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
      classification_value
      scheme_origination_code
    ]
  end

  def assign_attributes(attributes_data_hash)
    super(attributes_data_hash.merge('type' => @type))
  end
end