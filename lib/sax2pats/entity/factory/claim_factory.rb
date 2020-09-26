class ClaimFactory < EntityFactory
  def entity_class
    Sax2pats::Claim
  end

  def claim
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::ClaimVersion
  end

  def attribute_keys
    ['claim_id']
  end

  def assign_attributes(attributes_data_hash)
    @entity.element = attributes_data_hash.dup
    @entity.element.delete_if { |k, _v| attribute_keys.include?(k) }
    super(attributes_data_hash)
  end
end
