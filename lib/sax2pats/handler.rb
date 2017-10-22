module Sax2pats
  class Handler

    attr_accessor :parser,
                  :patent_handler,
                  :xml_version

    def initialize(file, patent_handler)
      @parser = Saxerator.parser(file) do |config|
        config.adapter = :ox
        config.put_attributes_in_hash!
        config.document_fragment_tags = ['abstract', 'description', 'othercit']
      end
      @patent_handler = patent_handler
      @xml_version = Sax2pats::XMLVersion4_5.new
    end

    def parse_patents
      @parser.for_tag(@xml_version.patent_tag(:grant)).each do |patent_grant_hash|
        patent = @xml_version.process_patent_grant(patent_grant_hash)
        @patent_handler.call(patent)
      end
    end
  end
end
