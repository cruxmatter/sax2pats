class PatentFactory < EntityFactory
  def entity_class
    Sax2pats::Patent
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

    assign_children(entities_data_hash, 'inventors', :inventors, InventorFactory)
    assign_children(entities_data_hash, 'claims', :claims, ClaimFactory)
    assign_children(entities_data_hash, 'drawings', :drawings, DrawingFactory)
    assign_children(entities_data_hash, 'citations', :citations, CitationFactory)
    assign_children(entities_data_hash, 'ipc_classifications', :classifications, IPCClassificationFactory)
    assign_children(entities_data_hash, 'national_classifications', :classifications, NationalClassificationFactory)
    assign_cpc_classifications(entities_data_hash)
  end

  def assign_cpc_classifications(entities_data_hash)
    %w[
      main_cpc
      further_cpc
    ].each do |type|
      @entity_version_adaptor
        .enumerate_child_entities(
          entities_data_hash.fetch(type)
        ) do |child_entity_hash|

        @entity.classifications << CPCClassificationFactory.new(
          @xml_version_adaptor,
          child_entity_hash,
          type
        ).entity
      end
    end
  end

  def assign_children(entities_data_hash, entities_key, entity_list, entity_factory_class)
    @entity_version_adaptor
      .enumerate_child_entities(
        entities_data_hash.fetch(entities_key)
      ) do |child_entity_hash|

      @entity.send(entity_list) <<
        entity_factory_class.new(
          @xml_version_adaptor,
          child_entity_hash
        ).entity
    end
  end
end
