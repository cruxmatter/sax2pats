module Sax2pats
  class Patent
    include DynamicAttrs
    attr_accessor :inventors, :citations

    def initialize
      @inventors = []
      @citations = []
    end
  end
end
