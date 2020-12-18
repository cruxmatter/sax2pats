class ClaimFactory < EntityFactory
  ENTITY_KEY = 'claim'.freeze

  def entity_class
    Sax2pats::Claim
  end

  def claim
    @entity
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
