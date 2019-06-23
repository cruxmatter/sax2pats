module Sax2pats
  class Handler

    attr_accessor :parser,
                  :patent_handler,
                  :xml_version,
                  :patent_types

    def initialize(file, patent_handler, patent_types: nil)
      @parser = Saxerator.parser(file) do |config|
        config.adapter = :ox
        config.put_attributes_in_hash!
      end
      @patent_handler = patent_handler
      @patent_types = patent_types.map(&:to_sym) if patent_types
      @xml_version = version_adaptor_class.new
    end

    def parse_patents
      @parser.for_tag(@xml_version.patent_tag(:grant)).each do |patent_grant_hash|
        patent_type = @xml_version.patent_type(patent_grant_hash).to_sym
        next unless @patent_types.nil? || (@patent_types || []).include?(patent_type)
        patent = PatentFactory.new(@xml_version, patent_grant_hash).patent
        @patent_handler.call(patent)
      end
    end

    def version
      # TODO: dynamically look up XML version
      # TODO: raise error if invalid version
      '4.5'
    end

    def version_adaptor_class
      case version
      when '4.5'
        Sax2pats::XMLVersion4_5
      end
    end
  end
end
