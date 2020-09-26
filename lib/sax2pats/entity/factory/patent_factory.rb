class PatentFactory < EntityFactory
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

    default_entity_definitions.each do |child_definition_hash|
      assign_children(**child_definition_hash.merge(data: entities_data_hash))
    end

    assign_cpc_classifications(entities_data_hash)
  end

  def assign_children(adapter_method:, key:, data:, list:, factory_class:)
    @entity_version_adaptor
      .send(
        adapter_method,
        data.fetch(key)
      ) do |child_entity_hash|

      factory =
        factory_class.new(
          @xml_version_adaptor
        )
      @entity.send(list) << factory.create(child_entity_hash)
    end
  end

  def assign_cpc_classifications(entities_data_hash)
    CPCClassificationFactory::TYPES.each do |type|
      @entity_version_adaptor
        .enumerate_child_entities(
          entities_data_hash.fetch(type)
        ) do |child_entity_hash|
        cpc_factory = custom_factories[:cpc_classifications] || CPCClassificationFactory.new(
          @xml_version_adaptor
        )

        @entity.classifications << cpc_factory.create(child_entity_hash, type)
      end
    end
  end

  private

  def default_entity_definitions
    [
      {
        key: 'inventors',
        adapter_method: :enumerate_child_inventors,
        list: :inventors,
        factory_class: InventorFactory
      },
      {
        key: 'assignees',
        adapter_method: :enumerate_child_assignees,
        list: :assignees,
        factory_class: AssigneeFactory
      },
      {
        key: 'examiners',
        adapter_method: :enumerate_child_examiners,
        list: :examiners,
        factory_class: ExaminerFactory
      },
      {
        key: 'applicants',
        adapter_method: :enumerate_child_applicants,
        list: :applicants,
        factory_class: ApplicantFactory
      },
      {
        key: 'claims',
        adapter_method: :enumerate_child_claims,
        list: :claims,
        factory_class: ClaimFactory
      },
      {
        key: 'drawings',
        adapter_method: :enumerate_child_drawings,
        list: :drawings,
        factory_class: DrawingFactory
      },
      {
        key: 'citations',
        adapter_method: :enumerate_child_citations,
        list: :citations,
        factory_class: CitationFactory
      },
      {
        key: 'ipc_classifications',
        adapter_method: :enumerate_child_ipc_classifications,
        list: :classifications,
        factory_class: IPCClassificationFactory
      },
      {
        key: 'national_classifications',
        adapter_method: :enumerate_child_national_classifications,
        list: :classifications,
        factory_class: NationalClassificationFactory
      }
    ]
  end
end
