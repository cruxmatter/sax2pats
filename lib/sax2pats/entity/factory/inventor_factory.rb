class InventorFactory < EntityFactory
  def entity_class
    Sax2pats::Inventor
  end

  def entity_key
    'inventor'
  end

  def inventor
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::InventorVersion
  end

  def attribute_keys
    %w[
      address
      first_name
      last_name
    ]
  end

  def assign_entities(entities_data_hash); end
end
