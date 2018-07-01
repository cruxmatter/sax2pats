module Sax2pats
  class Drawing
    include Entity
    attr_accessor :img, :figure, :description

    def initialize(from_version)
      super(from_version)
      @img = {}
      @figure = {}
    end
  end
end
