module Sax2pats
  class Claim
    include Entity
    attr_accessor :refs, :text, :claim_id

    def initialize
      @refs = []
      @text = ''
    end
  end
end
