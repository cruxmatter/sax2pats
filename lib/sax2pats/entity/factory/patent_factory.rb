class PatentFactory < EntityFactory
  ENTITY_KEY = 'patent'.freeze
  
  attr_accessor :custom_factories

  def custom_factories
    @custom_factories || {}
  end

  def entity_class
    raise NotImplementedError
  end

  def patent
    @entity
  end

  def attribute_keys
    # TODO move to constant
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
      patent_citations: {
        type: 'array',
        factory_class: PatentCitationFactory,
      },
      other_citations: {
        type: 'array',
        factory_class: OtherCitationFactory,
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

  def assign_child_entities(entities_data_hash)
    @entity.abstract = Sax2pats::PatentAbstract.new(
      element: find_attribute('abstract', entities_data_hash)
    )
    @entity.description = Sax2pats::PatentDescription.new(
      element: find_attribute('description', entities_data_hash)
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
    factory =
        factory_class.new(
          @xml_version_adaptor
        )

    # TODO: refactor
    child_or_children = nil

    self.class.ancestors.each do |klass|
      break if klass == EntityFactory
      entity_data = @xml_version_adaptor.transform_entity_data(
        klass::ENTITY_KEY,
        key,
        data
      )
      child_or_children = entity_data if entity_data
    end

    child_or_children = @xml_version_adaptor.filter_entity_data(
      self.class::ENTITY_KEY,
      key,
      child_or_children
    )
    
    if Sax2pats::Utility.is_array? child_or_children
      child_or_children.each do |child_entity_hash|
        @entity.send(key) << factory.create(child_entity_hash)
      end
    elsif Sax2pats::Utility.is_hash? child_or_children
      @entity.send(key) << factory.create(child_or_children)
    end
  end

  def assign_cpc_classifications(entities_data_hash)
    CPCClassificationFactory::TYPES.each do |type|

      # TODO: refactor
      child_entity_hash = nil

      self.class.ancestors.each do |klass|
        break if klass == EntityFactory
        child_entity_hash = @xml_version_adaptor.transform_entity_data(
          klass::ENTITY_KEY,
          type,
          entities_data_hash
        )

        next unless child_entity_hash

        if Sax2pats::Utility.is_array?(child_entity_hash)
          child_entity_hash.each do |e|
              cpc_factory = custom_factories[:cpc_classifications] || CPCClassificationFactory.new(
                @xml_version_adaptor
              )

              @entity.cpc_classifications << cpc_factory.create(e, type)
          end
        elsif Sax2pats::Utility.is_hash?(child_entity_hash)
          cpc_factory = custom_factories[:cpc_classifications] || CPCClassificationFactory.new(
            @xml_version_adaptor
          )

          @entity.cpc_classifications << cpc_factory.create(child_entity_hash, type)
        end
      end
    end
  end
end
