module Sax2pats
  module Entity
    attr_accessor :from_version

    def initialize(from_version)
      @from_version = from_version
    end

    def self.element_as_text(text_element)
      if text_element.kind_of?(Saxerator::Builder::HashElement)
        text_element.values.map{|v| Sax2pats::Entity.element_as_text(v).strip.chomp }.join(' ')
      elsif text_element.kind_of?(Saxerator::Builder::ArrayElement) || text_element.kind_of?(Array)
        text_element.map{|e| Sax2pats::Entity.element_as_text(e).strip.chomp }.join(' ')
      elsif text_element.kind_of?(Saxerator::Builder::StringElement) || text_element.kind_of?(String)
        text_element.to_s
      end
    end

    def self.doc_as_text(text_element)
      text_element.text.to_s
        .concat(text_element.elements.map{|el| Sax2pats::Entity.doc_as_text(el).strip.chomp}.join(' ') )
    end
  end
end
