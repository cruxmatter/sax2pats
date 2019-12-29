module Sax2pats
  class Processor
    attr_accessor :file,
                  :patent_handler,
                  :xml_version_adapter,
                  :included_patent_states,
                  :included_patent_types

    def initialize(file, patent_handler)
      @file = file
      @patent_handler = patent_handler

      @config = Configuration.new

      yield @config if block_given?

      @included_patent_types = 
        if @config.included_patent_types
          @config.included_patent_types.map(&:to_sym)
        else
          []
        end

      after_initialize
    end

    def parser
      @parser ||= Saxerator.parser(file) do |sax_config|
        sax_config.adapter = :ox
        sax_config.put_attributes_in_hash!
      end
    end

    def parse_patents; end

    def after_initialize; end
  end
end