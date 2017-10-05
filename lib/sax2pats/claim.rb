module Sax2pats
  class Claim
    include Entity
    attr_accessor :refs, :text_elements, :claim_id, :type

    def initialize
      @refs = []
      @text_elements = []
    end

    def type
      @type ||= @refs.count > 0 ? :dependent : :independent
    end

    def as_text
      @text_elements.join
    end
  end
end
