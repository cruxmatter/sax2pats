class PatentApplicationFactory < PatentFactory
  def entity_class
    PatentApplication
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::PatentApplicationVersion
  end
end
