class EntityFactory
  attr_accessor :entity, :xml_version_adaptor

  def initialize(xml_version_adaptor)
    @xml_version_adaptor = xml_version_adaptor
  end

  def create(data_hash)
    @entity = entity_class.new(@xml_version_adaptor.class::VERSION)

    entity_data = get_entity_data(data_hash)

    assign_attributes(entity_data)
    assign_child_entities(entity_data)

    @entity
  end

  protected

  def get_entity_data(data_hash)
    # Merge data from base classes (e.g. Patent for PatentGrant), 
    # but the result must be a Saxerator hash
    entity_data = nil
    self.class.ancestors.each do |klass|
      break if klass == EntityFactory
      data = @xml_version_adaptor.transform_entity_data(
        nil,
        klass::ENTITY_KEY,
        data_hash
      )
      entity_data = entity_data ? entity_data.merge!(data) : data
      entity_data.merge!(data)
    end
    # TODO: raise error if data empty
    entity_data
  end

  def attribute_types
    {}
  end

  def attribute_keys
    raise NotImplementedError
  end

  def child_entity_types
    {}
  end

  def coerce_type(attr_key, attr_value)
    case attribute_types[attr_key]
    when 'int'
      attr_value.to_i
    when 'date'
      Date.parse attr_value
    else
      attr_value
    end
  end
  
  def find_attribute(attribute_key, data_hash)
    self.class.ancestors
      .take_while { |klass| klass != EntityFactory }
      .map { |klass| @xml_version_adaptor.transform_attribute_data(klass::ENTITY_KEY, attribute_key, data_hash) }
      .detect { |attr_value| attr_value }
  end

  def assign_attributes(data_hash)
    attribute_keys.each do |attribute_key|
      attr_value = find_attribute(attribute_key, data_hash)
      next unless attr_value
      @entity.public_send("#{attribute_key}=", coerce_type(attribute_key, attr_value))
    end
  end

  def assign_child_entities(data_hash); end

  def entity_class
    raise NotImplementedError
  end
end
