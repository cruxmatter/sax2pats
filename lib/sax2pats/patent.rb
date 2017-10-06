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
                  :doc_number,
                  :category,
                  :date,
                  :number_of_claims,
                  :kind,
                  :abstract,
                  :description

    def initialize
      @abstract = ''
      @description = ''
      @inventors = []
      @citations = []
      @claims = []
      @drawings = []
      @classifications = []
    end

    def publication_reference
      [@doc_number, @date, @country, @kind]
    end
  end
end
