class PatentGrantFactory < PatentFactory
  def entity_class
    Sax2pats::PatentGrant
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::PatentGrantVersion
  end
end
