class PatentGrantFactory < PatentFactory
  def entity_class
    PatentGrant
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::PatentGrantVersion
  end
end
