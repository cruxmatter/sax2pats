module Sax2pats
  module EntityVersion
    attr_reader :entity

    def read_hash(entity_hash)
      raise NotImplementedError
    end
  end

  module XMLVersion
    def patent_tag(mode)
      raise NotImplementedError
    end

    def patent_type(patent_grant_hash)
      raise NotImplementedError
    end

    def process_patent_grant(patent_grant_hash)
      raise NotImplementedError
    end
  end
end
