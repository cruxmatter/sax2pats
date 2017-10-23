module Sax2pats
  class Claim
    include Entity
    attr_accessor :refs, :text_elements, :claim_id

    def initialize
      @refs = []
      @text_elements = []
    end

    def as_text
      @text_elements.join
    end
  end
end
