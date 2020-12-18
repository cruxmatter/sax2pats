class PatentApplicationFactory < PatentFactory
  ENTITY_KEY = 'patent_application'.freeze

  def entity_class
    Sax2pats::PatentApplication
  end

  def attribute_keys
    super + ['series_code']
  end

  def attribute_types
    {
      'series_code' => 'int',
    }
  end
end
