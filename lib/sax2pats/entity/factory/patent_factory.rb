class PatentFactory < EntityFactory
  def entity_class
    Sax2pats::Patent
  end

  def entity_key
    'patent'
  end

  def patent
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::PatentGrantVersion
  end

  def attribute_keys
    [
      'invention_title',
      'publication_reference',
      'application_reference',
      'number_of_claims',
      'patent_type'
    ]
  end

  def assign_entities(entities_data_hash)
    @entity.abstract = Sax2pats::PatentAbstract.new(
      element: entities_data_hash.fetch('abstract')
    )
    @entity.description = Sax2pats::PatentDescription.new(
      element: entities_data_hash.fetch('description')
    )

    @entity_version_adaptor
      .enumerate_child_entities(
        entities_data_hash.fetch('inventors')
      ) do |child_entity_hash|

      @entity.inventors <<
        InventorFactory.new(
          @xml_version_adaptor,
          child_entity_hash
        ).inventor
    end

    @entity_version_adaptor
      .enumerate_child_entities(
        entities_data_hash.fetch('claims')
      ) do |child_entity_hash|

      @entity.claims <<
        ClaimFactory.new(
          @xml_version_adaptor,
          child_entity_hash
        ).claim
    end
  end
end
