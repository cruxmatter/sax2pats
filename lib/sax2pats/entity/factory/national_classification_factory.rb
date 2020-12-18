class NationalClassificationFactory < EntityFactory
  ENTITY_KEY = 'national_classification'.freeze

  def entity_class
    Sax2pats::NationalClassification
  end

  def national_classification
    @entity
  end

  def attribute_keys
    %w[
      country
      main_classification
      further_classification
    ]
  end
end
