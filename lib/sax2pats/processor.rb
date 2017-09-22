module Sax2pats
  class Processor < Ox::Sax

    attr_accessor :current_tag, :active_tags, :patent, :inventor, :citation, :patent_handler

    def initialize(patent_handler)
      @active_tags = []
      @patent_handler = patent_handler
      # @include_tags = []
      # @exclude_tags = []
    end

    def start_element(name)
      @current_tag = name.to_s
      if @current_tag.eql?('us-patent-grant')
        @patent = Patent.new
      elsif @current_tag.eql?('inventor')
        @inventor = Inventor.new
      elsif @current_tag.eql?('us-citation')
        @citation = Citation.new
      end
      @active_tags.push(@current_tag)
    end

    def attr(name, value)

    end

    def value(value)
      value = value.as_s
      if @active_tags.include?('inventor')
        @inventor.assign(@current_tag.to_sym, value)
      elsif @active_tags.include?('us-citation')
        @citation.assign(@current_tag.to_sym, value)
      elsif @active_tags.include?('us-patent-grant')
        @patent.assign(@current_tag.to_sym, value)
      end
    end

    def end_element(name)
      name = name.to_s
      if name.eql?('us-patent-grant')
          @patent_handler.call(@patent)
      elsif name.eql?('inventor')
        @patent.inventors << @inventor
      elsif name.eql?('us-citation')
        @patent.citations << @citation
      end
      @active_tags.pop
    end
  end
end
