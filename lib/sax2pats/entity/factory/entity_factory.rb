class EntityFactory
  attr_accessor :entity, :xml_version_adaptor

  def initialize(xml_version_adaptor, data_hash)
    @xml_version_adaptor = xml_version_adaptor
    @entity_version_adaptor = entity_version_adaptor_class(
      xml_version_adaptor.class
    ).new(data_hash)

    data = @entity_version_adaptor.entity_attribute_hash

    @entity = entity_class.new(xml_version_adaptor.class::VERSION)

    assign_attributes(data)
    assign_entities(data)
  end

  def attribute_keys
    raise NotImplementedError
  end

  def assign_attributes(attributes_data_hash)
    # TODO types?
    attributes_data_hash
      .select { |k, _v| attribute_keys.include? k }
      .each { |k,v| @entity.public_send("#{k}=", v) }
  end

  def assign_entities(entities_data_hash); end

  def entity_version_adaptor_class(_xml_version_adaptor_class)
    raise NotImplementedError
  end

  def entity_class
    raise NotImplementedError
  end
end
