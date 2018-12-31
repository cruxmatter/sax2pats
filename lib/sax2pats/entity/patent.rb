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
                  :citations,
                  :claims,
                  :drawings,
                  :tables,
                  :classifications,
                  :classification_national,
                  :invention_title,
                  :publication_reference,
                  :application_reference,
                  :number_of_claims,
                  :abstract,
                  :description
    attr_reader :description_text, :abstract_text

    def initialize(from_version)
      super(from_version)
      @publication_reference = {}
      @application_reference = {}
      @inventors = []
      @citations = []
      @claims = []
      @drawings = []
      @classifications = []
    end
  end
end
