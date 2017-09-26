module Sax2pats
  class Patent
    include DynamicAttrs
    attr_accessor :inventors,
                  :citations,
                  :claims,
                  :drawings,
                  :tables,
                  :abstract,
                  :description,
                  :classifications

    def initialize
      @abstract = ''
      @inventors = []
      @citations = []
      @claims = []
      @drawings = []
      @classifications = []
    end
  end
end
