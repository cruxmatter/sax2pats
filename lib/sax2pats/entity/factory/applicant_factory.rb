class ApplicantFactory < EntityFactory
  ENTITY_KEY = 'applicant'.freeze

  def entity_class
    Sax2pats::Applicant
  end

  def applicant
    @entity
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
