module Sax2pats
  class SingleProcessor < Processor
    def after_initialize
      return if noop?

      @xml_version_adaptor = @config.xml_version_adaptor(version)
    end

    def noop?
      !@config.included_patent_states.include?(doctype) || version.nil?
    end

    def parse_patents
      return if noop?
      return unless @xml_version_adaptor

      parser.for_tag(@xml_version_adaptor.patent_tag(:grant)).each do |patent_grant_hash|
        patent_type = @xml_version_adaptor.patent_type(patent_grant_hash).to_sym
        next unless @included_patent_types.include?(patent_type)

        custom_factories = {}

        if @config.include_cpc_metadata?
          custom_factories[:cpc_classifications] =
            CPCClassificationFactory.new(
              @xml_version_adaptor,
              cpc_metadata: @config.cpc_metadata
            )
        end

        patent_factory = PatentFactory.new(
          @xml_version_adaptor
        )
        patent_factory.custom_factories = custom_factories
        @patent_handler.call(patent_factory.create(patent_grant_hash))
      end
    end

    def doctype_node
      @doctype_node ||= begin
        e = @file.each_line
        @doctype = e.detect { |l| l =~ /DOCTYPE/ }
        e.rewind
        Ox.parse(@doctype).nodes.first.value
      end
    end

    def doctype
      @doctype ||= doctype_node.split(' ')[0]
    end

    def version
      v = doctype_node.split(' ')[2].split('-')[3]
      case v
      when 'v45'
        '4.5'
      when 'v41'
        '4.1'
      end
    end
  end
end
