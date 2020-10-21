class EntityFactory
  attr_accessor :entity, :xml_version_adaptor

  def initialize(xml_version_adaptor)
    @xml_version_adaptor = xml_version_adaptor
    @entity_version_adaptor_class = entity_version_adaptor_class(
      @xml_version_adaptor.class
    )
  end

  def create(data_hash)
    @entity_version_adaptor = @entity_version_adaptor_class.new(data_hash)
    @entity_data = @entity_version_adaptor.entity_attribute_hash

    @entity = entity_class.new(@xml_version_adaptor.class::VERSION)

    assign_attributes(@entity_data)
    assign_entities(@entity_data)

    @entity
  end

  protected

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

  def assign_attributes(attributes_data_hash)
    attributes_data_hash
      .select { |k, _v| attribute_keys.include? k }
      .each { |k,v| @entity.public_send("#{k}=", coerce_type(k, v)) }
  end

  def assign_entities(entities_data_hash); end

  def entity_version_adaptor_class(_xml_version_adaptor_class)
    raise NotImplementedError
  end

  def entity_class
    raise NotImplementedError
  end
end
