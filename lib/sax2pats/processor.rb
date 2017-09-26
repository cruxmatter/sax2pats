module Sax2pats
  class Processor < Ox::Sax

    attr_accessor :current_tag,
                  :active_tags,
                  :current_entity,
                  :patent,
                  :inventor,
                  :citation,
                  :claim,
                  :drawing,
                  :patent_handler,
                  :classification

    def initialize(patent_handler)
      @active_tags = []
      @patent_handler = patent_handler
      @classification_roots = ['classification-cpc', 'classification-ipcr']
    end

    def start_element(name)
      @current_tag = name.to_s
      if @current_tag.eql?('us-patent-grant')
        @patent = Patent.new
        @current_entity = @patent
      elsif @classification_roots.include?(@current_tag)
        @classification = {}
      elsif @current_tag.eql?('inventor')
        @inventor = Inventor.new
        @current_entity = @inventor
      elsif @current_tag.eql?('us-citation')
        @citation = Citation.new
        @current_entity = @citation
      elsif @current_tag.eql?('claim')
        @claim = Claim.new
        @current_entity = @claim
      elsif @current_tag.eql?('description-of-drawings')
        # drawing <p> tag not being read
        @drawing = Drawing.new
        @current_entity = @drawing
      end
      @active_tags.push(@current_tag)
    end

    def attr(name, value)
      if @current_tag.eql?('claim')
        if name.eql? :id
          @claim.claim_id = value
        end
      elsif @current_tag.eql?('claim-ref')
        if name.eql? :idref
          @claim.refs << value
        end
      end
    end

    def text(value)

    end

    def value(value)
      str_value = value.as_s
      if @classification
        @classification[@current_tag] = str_value
      elsif @active_tags.include?('inventor')
        @inventor.assign(@current_tag.to_sym, str_value)
      elsif @active_tags.include?('us-citation')
        @citation.assign(@current_tag.to_sym, str_value)
      elsif @active_tags.include?('claim')
        if @current_tag.eql?('claim-text')
          @claim.text.concat(" #{str_value.lstrip}")
        elsif @current_tag.eql?('claim-ref')
          @claim.text.concat(str_value)
        end
      elsif @active_tags.include?('description-of-drawings')
        @drawing.assign(@current_tag.to_sym, str_value)
      elsif @active_tags.include?('us-patent-grant')
        if @active_tags.include?('abstract')
          @patent.abstract.concat(str_value)
        else
          @patent.assign(@current_tag.to_sym, str_value)
        end
      end
    end

    def end_element(name)
      name = name.to_s
      if name.eql?('us-patent-grant')
        @patent_handler.call(@patent)
      elsif @classification_roots.include?(name)
        @current_entity.classifications << @classification
        @classification = nil
      elsif name.eql?('inventor')
        @patent.inventors << @inventor
      elsif name.eql?('us-citation')
        @patent.citations << @citation
      elsif name.eql?('claim')
        @claim.text.lstrip.strip
        @patent.claims << @claim
      elsif name.eql?('description-of-drawings')
        @patent.drawings << @drawing
      end
      @active_tags.pop
    end
  end
end
