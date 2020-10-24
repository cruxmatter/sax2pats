class EntityFactory
  attr_accessor :entity, :xml_version_adaptor

  def initialize(xml_version_adaptor)
    @xml_version_adaptor = xml_version_adaptor
  end

  def create(data_hash)
    set_entity_data(data_hash)

    @entity = entity_class.new(@xml_version_adaptor.class::VERSION)

    assign_attributes(@entity_data)
    assign_entities(@entity_data)

    @entity
  end

  protected

  def set_entity_data(data_hash)
    self.class.ancestors.each do |klass|
      @entity_data = @xml_version_adaptor.get_entity_data(
        nil,
        klass::ENTITY_KEY,
        data_hash
      )
      break if @entity_data
      break if klass = EntityFactory
    end
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

  def assign_attributes(data_hash)
    attribute_keys.each do |key|
      attr_value = @xml_version_adaptor.get_attribute_data(key, data_hash)
      @entity.public_send("#{key}=", coerce_type(key, attr_value))
    end
  end

  def assign_entities(data_hash); end

  def entity_class
    raise NotImplementedError
  end
end
