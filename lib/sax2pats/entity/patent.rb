module Sax2pats
  class PatentAbstract
    include Sax2pats::DocEntity

    def initialize(element: nil)
      @element = element
    end
  end

  class PatentDescription
    include Sax2pats::DocEntity

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
                  :citations,
                  :claims,
                  :drawings,
                  :tables,
                  :classifications,
                  :invention_title,
                  :publication_reference,
                  :application_reference,
                  :number_of_claims,
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
      @citations = []
      @claims = []
      @drawings = []
      @classifications = []
    end

    def ipc_classifications
      @classifications.select do |classification|
        classification.class == Sax2pats::IPCClassification
      end
    end

    def cpc_classifications
      @classifications.select do |classification|
        classification.class == Sax2pats::CPCClassification
      end
    end

    def national_classifications
      @classifications.select do |classification|
        classification.class == Sax2pats::NationalClassification
      end
    end
  end
end
