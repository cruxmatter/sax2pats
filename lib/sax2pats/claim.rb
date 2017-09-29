module Sax2pats
  class Claim
    include Element
    attr_accessor :refs, :text, :claim_id

    def initialize
      @refs = []
      @text = ''
    end
  end
end
