module Sax2pats
  class Handler

    attr_accessor :parser,
                  :patent_handler,
                  :xml_version,
                  :patent_types

    def initialize(file, patent_handler, patent_types: [])
      @parser = Saxerator.parser(file) do |config|
        config.adapter = :ox
        config.put_attributes_in_hash!
      end
      @patent_handler = patent_handler
      @patent_types = patent_types
      @xml_version = Sax2pats::XMLVersion4_5.new
    end

    def parse_patents
      @parser.for_tag(@xml_version.patent_tag(:grant)).each do |patent_grant_hash|
        next unless @patent_types.include? @xml_version.patent_type(patent_grant_hash)
        patent = @xml_version.process_patent_grant(patent_grant_hash)
        @patent_handler.call(patent)
      end
    end
  end
end
