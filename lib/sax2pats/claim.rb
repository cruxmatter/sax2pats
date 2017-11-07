module Sax2pats
  class Claim
    include Entity
    attr_accessor :text_hash, :claim_id
    attr_reader :text, :refs

    def refs
      # TODO
    end

    def text
      @text ||= Sax2pats::Entity.hash_as_text(@text_hash)
    end
  end
end
