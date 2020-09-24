class CitationFactory < EntityFactory
  def entity_class
    if @entity_data['patent_citation']
      PatentCitation
    elsif @entity_data['other_citation']
      OtherCitation
    else
      raise StandardError.new('Unknown citation type')
    end
  end

  def patent_citation
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::CitationVersion
  end

  def attribute_keys
    if @entity_data['patent_citation']
      %w[
        category
        document_id
        classification_cpc_text
        classification_national
        us_field_of_classification_search
      ]
    elsif @entity_data['other_citation']
      %w[
        citation_value
      ]
    end
  end

  def assign_entities(entities_data_hash)
    unless entities_data_hash.dig('classification_national').nil?
      national_class_factory = NationalClassificationFactory.new(
        @xml_version_adaptor
      )

      @entity.classification_national = 
        national_class_factory.create(
          entities_data_hash.dig('classification_national')
        )
    end
  end
end
