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

  def attribute_types
    {
      'number_of_claims' => 'int'
    }
  end

  def assign_entities(entities_data_hash)
    @entity.abstract = Sax2pats::PatentAbstract.new(
      element: entities_data_hash.fetch('abstract')
    )
    @entity.description = Sax2pats::PatentDescription.new(
      element: entities_data_hash.fetch('description')
    )

    [
      {
        data: entities_data_hash,
        key: 'inventors',
        adapter_method: :enumerate_child_inventors,
        list: :inventors,
        factory: InventorFactory
      },
      {
        data: entities_data_hash,
        key: 'claims',
        adapter_method: :enumerate_child_claims,
        list: :claims,
        factory: ClaimFactory
      },
      {
        data: entities_data_hash,
        key: 'drawings',
        adapter_method: :enumerate_child_drawings,
        list: :drawings,
        factory: DrawingFactory
      },
      {
        data: entities_data_hash,
        key: 'citations',
        adapter_method: :enumerate_child_citations,
        list: :citations,
        factory: CitationFactory
      },
      {
        data: entities_data_hash,
        key: 'ipc_classifications',
        adapter_method: :enumerate_child_ipc_classifications,
        list: :classifications,
        factory: IPCClassificationFactory
      },
      {
        data: entities_data_hash,
        key: 'national_classifications',
        adapter_method: :enumerate_child_national_classifications,
        list: :classifications,
        factory: NationalClassificationFactory
      }
    ].each do |child_definition_hash|
      assign_children(**child_definition_hash)
    end

    assign_cpc_classifications(entities_data_hash)
  end

  def assign_children(adapter_method:, key:, data:, list:, factory:)
    @entity_version_adaptor
      .send(
        adapter_method,
        data.fetch(key)
      ) do |child_entity_hash|

      @entity.send(list) <<
        factory.new(
          @xml_version_adaptor,
          child_entity_hash
        ).entity
    end
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
end
