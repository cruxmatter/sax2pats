module Sax2pats
  class PatentAbstract
    include DocEntity

    def initialize(element: nil)
      @element = element
    end
  end

  class PatentDescription
    include DocEntity

    def initialize(element: nil)
      @element = element
    end
  end

  class Patent
    include Entity
    attr_accessor :inventors,
                  :assignees,
                  :examiners,
                  :applicants,
                  :patent_citations,
                  :other_citations,
                  :claims,
                  :drawings,
                  :tables,
                  :ipc_classifications,
                  :cpc_classifications,
                  :national_classifications,
                  :invention_title,
                  :publication_reference,
                  :application_reference,
                  :abstract,
                  :description,
                  :patent_type
    attr_reader :description_text, :abstract_text

    def initialize(from_version)
      super(from_version)
      @publication_reference = {}
      @application_reference = {}
      @inventors = []
      @assignees = []
      @examiners = []
      @applicants = []
      @patent_citations = []
      @other_citations = []
      @claims = []
      @drawings = []
      @national_classifications = []
      @ipc_classifications = []
      @cpc_classifications = []
    end

    def citations
      @patent_citations + @other_citations
    end

    def classifications
      national_classifications +
      ipc_classifications +
      cpc_classifications
    end
  end
end
