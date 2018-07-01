module Sax2pats
  class Claim
    include Entity
    attr_accessor :text_element, :claim_id
    attr_reader :text, :refs

    def refs
      @refs ||= collect_refs(@text_element)
    end

    def text
      @text ||= Sax2pats::Entity.element_as_text(@text_element)
    end

    private

    def collect_refs(element)
      if element.kind_of?(Saxerator::Builder::HashElement) || element.kind_of?(Hash)
        element.keys.each do |k|
          # TODO: consider moving into XMLVersion
          if k.eql?('claim-ref')
            return element.fetch('claim-ref').attributes.fetch('idref')
          else
            return element.keys.map{ |k| collect_refs(element[k]) }.flatten.compact
          end
        end
      elsif element.kind_of?(Saxerator::Builder::ArrayElement) || element.kind_of?(Array)
        return element.map{ |e| collect_refs(e) }.flatten.compact
      end
    end
  end
end
