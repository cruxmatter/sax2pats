module Sax2pats
  class Claim
    include Entity
    include DocEntity
    attr_accessor :element, :claim_id
    attr_reader :refs

    def refs
      @refs ||= collect_refs(@element)
    end

    private

    def collect_refs(element)
      if element.name.eql?('claim-ref')
        return element.attributes.fetch('idref')
      end

      if element.kind_of?(Saxerator::Builder::HashElement)
        element.keys.each do |k|
          return element.keys.map{ |k| collect_refs(element[k]) }.flatten.compact
        end
      elsif element.kind_of?(Saxerator::Builder::ArrayElement)
        return element.map{ |e| collect_refs(e) }.flatten.compact
      end
    end
  end
end