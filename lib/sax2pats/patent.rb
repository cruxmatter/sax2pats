module Sax2pats
  class Patent
    include Element
    attr_accessor :inventors,
                  :citations,
                  :claims,
                  :drawings,
                  :tables,
                  :classifications,
                  :invention_title,
                  :doc_number,
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

    # def publication_reference
    #   [self.doc_number, self.date, self.country, self.kind]
    # end
  end
end
