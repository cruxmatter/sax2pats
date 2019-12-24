module Sax2pats
  class Handler

    attr_accessor :parser,
                  :patent_handler,
                  :xml_version,
                  :patent_types

    def initialize(file, patent_handler)
      @file = file
      @parser = Saxerator.parser(file) do |sax_config|
        sax_config.adapter = :ox
        sax_config.put_attributes_in_hash!
      end
      @patent_handler = patent_handler
      @config = Configuration.new

      yield @config if block_given?

      if @config.patent_types
        @patent_types = @config.patent_types.map(&:to_sym)
      end

      @xml_version = version_adaptor_class.new if version_adaptor_class

      if @xml_version && @config.include_cpc_metadata?
        @xml_version.load_cpc_metadata
      end
    end

    def parse_patents
      return unless @xml_version

      @parser.for_tag(@xml_version.patent_tag(:grant)).each do |patent_grant_hash|
        patent_type = @xml_version.patent_type(patent_grant_hash).to_sym
        next unless @patent_types.empty? || @patent_types.include?(patent_type)

        patent = PatentFactory.new(@xml_version, patent_grant_hash).patent
        @patent_handler.call(patent)
      end
    end

    def doctype
      e = @file.each_line
      @doctype = e.take(2).last
      e.rewind
      @doctype
    end

    def version
      v = Ox.parse(doctype).nodes.first.value.split(' ')[2].split('-')[3]
      case v
      when 'v45'
        '4.5'
      when 'v41'
        '4.1'
      end
    end

    def version_adaptor_class
      case version
      when '4.5'
        Sax2pats::XMLVersion4_5
      when '4.1'
        Sax2pats::XMLVersion4_1
      end
    end
  end
end
