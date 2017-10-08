module Sax2pats
  class Patent
    include Entity
    attr_accessor :inventors,
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
                  :description

    def initialize
      @abstract = ''
      @description = ''
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
