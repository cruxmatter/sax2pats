class CitationFactory < EntityFactory
  ENTITY_KEY = 'citation'.freeze

end

class PatentCitationFactory < CitationFactory
  ENTITY_KEY = 'patent_citation'.freeze

  def entity_class
    Sax2pats::PatentCitation
  end

  def patent_citation
    @entity
  end

  def assign_child_entities(entities_data_hash)
    class_data_hash = find_attribute('classification_national', entities_data_hash)
    unless class_data_hash.nil?
      national_class_factory = NationalClassificationFactory.new(
        @xml_version_adaptor
      )

      @entity.classification_national = 
        national_class_factory.create(class_data_hash)
    end
  end

  def attribute_keys
    %w[
      category
      document_id
      classification_cpc_text
      classification_national
      us_field_of_classification_search
    ]
  end
end

class OtherCitationFactory < CitationFactory
  ENTITY_KEY = 'other_citation'.freeze

  def entity_class
    Sax2pats::OtherCitation
  end

  def other_citation
    @entity
  end

  def attribute_keys
    %w[
      citation_value
    ]
  end
end
