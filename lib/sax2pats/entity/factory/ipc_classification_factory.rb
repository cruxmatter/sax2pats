class IPCClassificationFactory < EntityFactory
  ENTITY_KEY = 'ipc_classification'.freeze

  def entity_class
    Sax2pats::IPCClassification
  end

  def ipc_classification
    @entity
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
