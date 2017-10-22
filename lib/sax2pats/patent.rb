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
    attr_reader :description_text

    def initialize
      @abstract = ''
      @publication_reference = {}
      @application_reference = {}
      @inventors = []
      @citations = []
      @claims = []
      @drawings = []
      @classifications = []
      @description_text = ""
    end

    def get_description_text(description_element)
      @description_text.concat(description_element.text.to_s)
      description_element.elements.each do |element|
        get_description_text(element)
      end
    end
  end
end
