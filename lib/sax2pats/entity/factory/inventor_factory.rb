class InventorFactory < EntityFactory
  ENTITY_KEY = 'inventor'.freeze

  def entity_class
    Sax2pats::Inventor
  end

  def inventor
    @entity
  end

  def attribute_keys
    %w[
      address
      first_name
      last_name
    ]
  end
end
