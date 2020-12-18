class PatentGrantFactory < PatentFactory
  ENTITY_KEY = 'patent_grant'.freeze

  def entity_class
    Sax2pats::PatentGrant
  end
end
