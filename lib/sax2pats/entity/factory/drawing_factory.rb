class DrawingFactory < EntityFactory
  def entity_class
    Drawing
  end

  def drawing
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::DrawingVersion
  end

  def attribute_keys
    %w[
      id
      img
      description
    ]
  end

  def assign_attributes(attributes_data_hash)
    @entity.element = attributes_data_hash.dup
    super(attributes_data_hash)
  end
end
