module Sax2pats
  class Drawing
    include Entity
    attr_accessor :img, :figure, :description

    def initialize
      @img = {}
      @figure = {}
    end
  end
end
