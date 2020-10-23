class PatentFactory < EntityFactory
  ENTITY_KEY = 'patent'.freeze
  
  attr_accessor :custom_factories

  def custom_factories
    @custom_factories || {}
  end

  def entity_class
    Sax2pats::Patent
  end

  def patent
    @entity
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
      number_of_claims: 'int'
    }
  end

  def child_entity_types
    {
      abstract: { type: Sax2pats::PatentAbstract  },
      description: { type: Sax2pats::PatentDescription },
      inventors: {
        type: 'array',
        factory_class: InventorFactory,
      },
      assignees: {
        type: 'array',
        factory_class: AssigneeFactory,
      },
      applicants: {
        type: 'array',
        factory_class: ApplicantFactory,
      },
      claims: {
        type: 'array',
        factory_class: ClaimFactory,
      },
      examiners: {
        type: 'array',
        factory_class: ExaminerFactory,
      },
      drawings: {
        type: 'array',
        factory_class: DrawingFactory,
      },
      citations: {
        type: 'array',
        factory_class: CitationFactory,
      },
      ipc_classifications: {
        type: 'array',
        factory_class: IPCClassificationFactory,
      },
      national_classifications: {
        type: 'array',
        factory_class: NationalClassificationFactory,
      },
    }
  end

  def assign_entities(entities_data_hash)
    @entity.abstract = Sax2pats::PatentAbstract.new(
      element: entities_data_hash.fetch('abstract')
    )
    @entity.description = Sax2pats::PatentDescription.new(
      element: entities_data_hash.fetch('description')
    )

    child_entity_types
      .select { |key, entity_type| entity_type.fetch(:type) == 'array' }
      .each do |key, entity_type|
        assign_array_children(**{ key: key, factory_class: entity_type.fetch(:factory_class) }
          .merge(data: entities_data_hash))
      end

    assign_cpc_classifications(entities_data_hash)
  end

  def assign_array_children(key:, data:, factory_class:)
    @xml_version_adaptor.get_entity_data(ENTITY_KEY, key, data) do |child_entity_hash|

      factory =
        factory_class.new(
          @xml_version_adaptor
        )
      @entity.send(key) << factory.create(child_entity_hash)
    end
  end

  def assign_cpc_classifications(entities_data_hash)
    CPCClassificationFactory::TYPES.each do |type|
      @entity_version_adaptor
        .get_entity_data(ENTITY_KEY, type, entities_data_hash) do |child_entity_hash|
          cpc_factory = custom_factories[:cpc_classifications] || CPCClassificationFactory.new(
            @xml_version_adaptor
          )

          @entity.classifications << cpc_factory.create(child_entity_hash, type)
      end
    end
  end
end
