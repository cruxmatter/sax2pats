module Sax2pats
  class Patent
    include DynamicAttrs
    attr_accessor :inventors,
                  :citations,
                  :claims,
                  :drawings,
                  #:tables,
                  :abstract

    def initialize
      @abstract = ''
      @inventors = []
      @citations = []
      @claims = []
      @drawings = []
    end
  end
end
