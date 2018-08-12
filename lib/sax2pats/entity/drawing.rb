module Sax2pats
  class Drawing
    include Entity
    include DocEntity
    attr_accessor :id, :figure, :img, :description

    def initialize(from_version)
      super(from_version)
      @img = {}
    end
  end
end
