class DrawingFactory < EntityFactory
  ENTITY_KEY = 'drawing'.freeze

  def entity_class
    Sax2pats::Drawing
  end

  def drawing
    @entity
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
