module Sax2pats
  class Drawing
    include Element
    attr_accessor :img, :figure, :description

    def initialize
      @img = {}
      @figure = {}
    end
  end
end
