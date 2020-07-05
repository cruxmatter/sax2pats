class ApplicantFactory < EntityFactory
  def entity_class
    Sax2pats::Applicant
  end

  def applicant
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::ApplicantVersion
  end

  def attribute_keys
    %w[
      address
      first_name
      last_name
      residence
      orgname
    ]
  end
end
