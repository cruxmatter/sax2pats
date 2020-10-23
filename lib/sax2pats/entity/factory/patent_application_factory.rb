class PatentApplicationFactory < PatentFactory
  def entity_class
    Sax2pats::PatentApplication
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::PatentApplicationVersion
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
