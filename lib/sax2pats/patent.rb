module Sax2pats
  class Patent
    include DynamicAttrs
    attr_accessor :inventors,
                  :citations,
                  :abstract

    def initialize
      @inventors = []
      @citations = []
    end
  end
end
