module Sax2pats
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

    def abstract_text
      @abstract_text ||= Sax2pats::Entity.doc_as_text(@abstract)
    end

    def description_text
      @description_text ||= Sax2pats::Entity.doc_as_text(@description)
    end
  end
end
