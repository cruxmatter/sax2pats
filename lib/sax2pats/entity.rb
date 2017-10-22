module Sax2pats
  module Entity
    attr_accessor :from_version

    def initialize(from_version: nil)
      @from_version = from_version
    end
  end
end
