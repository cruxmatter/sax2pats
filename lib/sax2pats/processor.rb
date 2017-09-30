module Sax2pats
  class Processor < Ox::Sax

    attr_accessor :current_tag,
                  :current_reader,
                  :patent_handler,
                  :xml_version

    def initialize(patent_handler)
      @patent_handler = patent_handler
      @xml_version = XMLVersion.new
    end

    def start_element(tag_name)
      @current_tag = tag_name.to_s
      if @xml_version.element_root([@current_tag]) == Sax2pats::Patent
        @current_reader = PatentReader.new(@xml_version)
      else
        unless @current_reader.nil?
          @current_reader.start_element(@current_tag)
        end
      end
    end

    def attr(name, value)
      # if @current_tag.eql?('claim')
      #   if name.eql? :id
      #     @claim.claim_id = value
      #   end
      # elsif @current_tag.eql?('claim-ref')
      #   if name.eql? :idref
      #     @claim.refs << value
      #   end
      # end
      # if @active_tags.include?('drawings')
      #   if @current_tag.eql?('img')
      #     @drawing.img[name] = value
      #   elsif @current_tag.eql?('figure')
      #     @drawing.figure[name] = value
      #   end
      # end
    end

    def text(value)

    end

    def value(value)
      str_value = value.as_s
      unless @current_reader.nil?
        @current_reader.value(value)
      end
      # if @active_tags.any?{|a| @classification_roots.include? a }
      #   @classification.assign(@current_tag.to_sym, str_value)
      # elsif @active_tags.include?('inventor')
      #   @inventor.assign(@current_tag.to_sym, str_value)
      # elsif @active_tags.include?('us-citation')
      #   @citation.assign(@current_tag.to_sym, str_value)
      # elsif @active_tags.include?('claim')
      #   if @current_tag.eql?('claim-text')
      #     @claim.text += " #{str_value.lstrip}"
      #   elsif @current_tag.eql?('claim-ref')
      #     @claim.text += str_value
      #   end
      # elsif @active_tags.include?('description')
      #   if @active_tags.include?('description-of-drawings')
      #
      #   else
      #     @description += str_value
      #   end
      # elsif @active_tags.include?('drawings')
      #   @drawing.assign(@current_tag.to_sym, str_value)
      # elsif @active_tags.include?('us-patent-grant')
      #   if @active_tags.include?('abstract')
      #     @patent.abstract += str_value
      #   else
      #     @patent.assign(@current_tag.to_sym, str_value)
      #   end
      # end
    end

    def end_element(tag_name)
      tag_name = tag_name.to_s
      if @xml_version.element_root([tag_name]) == Sax2pats::Patent
        @patent_handler.call(@current_reader.element)
      else
        @current_reader.end_element(tag_name) unless @current_reader.nil?
      end
    end
  end

  class XMLVersion
    # 4.2
    ELEMENT_ROOTS = {
      'us-patent-grant' => Sax2pats::Patent,
      'us-citation' => Sax2pats::Citation,
      'claim' => Sax2pats::Claim,
      'inventor' => Sax2pats::Inventor
    }

    NESTED_TEXT_TAGS = {
      Sax2pats::Patent => ['abstract', 'description'],
      Sax2pats::Claim => ['text']
    }

    def element_root(active_tags)
      if active_tags.include?('drawings') && active_tags.last.eql?('figure')
        Sax2pats::Drawing
      else
        ELEMENT_ROOTS[active_tags.last]
      end
    end

    def nested_text?(element, tag_name)
      NESTED_TEXT_TAGS[element].include?(tag_name)
    end
  end

  class TextReader
    attr_accessor :xml_version,
                  :root_tag,
                  :text

    def initialize(xml_version)
      @xml_version = xml_version
      initialize_element
    end

    def initialize_element
      @text = ""
    end

    def start_element(tag_name)
      unless tag_name.eql? @root_tag
        @text += "<#{tag_name}>"
      end
    end

    def value(value)
      @text += value.as_s
    end

    def end_element(tag_name)
      unless tag_name.eql? @root_tag
        @text += "</#{tag_name}>"
      end
    end
  end

  class ElementReader
    attr_accessor :xml_version,
                  :element,
                  :active_tags,
                  :current_child_reader,
                  :current_text_reader

    def initialize(xml_version)
      @xml_version = xml_version
      @active_tags = []
      initialize_element
    end

    def initialize_element
      raise NotImplementedError
    end

    def start_element(tag_name)
      raise NotImplementedError
    end

    def value(value)
      unless @active_tags.last.nil?
        element_attr = @element.sanitize(@active_tags.last).to_sym
        if @element.respond_to? element_attr
          @element.send("#{element_attr}=".to_sym, value.as_s)
        else
          # puts "undefined attribute #{element_attr}"
        end
      end
    end

    def attr(name, value)

    end

    def end_element(tag_name)
      raise NotImplementedError
    end

    def child_readers
      {}
    end
  end

  class PatentReader < ElementReader

    def initialize_element
      @element = Patent.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
      element = @xml_version.element_root(@active_tags)
      unless element.nil?
        @current_child_reader = child_readers[element].new(@xml_version)
      end
      if @current_child_reader.nil?
        # handle direct data
        if @xml_version.nested_text?(Sax2pats::Patent, tag_name)
          @current_text_reader = TextReader.new(@xml_version)
          @current_text_reader.root_tag = tag_name
        end
        unless @current_text_reader.nil?
          @current_text_reader.start_element(tag_name)
        end
      else
        @current_child_reader.start_element(tag_name)
      end
    end

    def value(value)
      if @current_child_reader.nil?
        if @current_text_reader.nil?
          super(value)
        else
          @current_text_reader.value(value)
        end
      else
        @current_child_reader.value(value)
      end
    end

    def attr(name, value)
      if @current_child_reader.nil?
        # handle direct data
      else
        @current_child_reader.attr(name, value)
      end
    end

    def end_element(tag_name)
      if @current_child_reader.nil?
        # handle direct data
        unless @current_text_reader.nil?
          @current_text_reader.end_element(tag_name)
          if @xml_version.nested_text?(Sax2pats::Patent, tag_name)
            element_attr = @element.sanitize(tag_name).to_sym
            @element.send("#{element_attr}=", @current_text_reader.text)
            @current_text_reader = nil
          end
        end
      else
        @current_child_reader.end_element(tag_name)
        if child_readers[@xml_version.element_root(@active_tags)] == @current_child_reader.class
          klass = @current_child_reader.element.class
          case
          when klass == Sax2pats::Claim
            @element.claims << @current_child_reader.element
          when klass == Sax2pats::Citation
            @element.citations << @current_child_reader.element
          when klass == Sax2pats::Inventor
            @element.inventors << @current_child_reader.element
          when klass == Sax2pats::Drawing
            @element.drawings << @current_child_reader.element
          else
          end
          @current_child_reader = nil
        end
      end
      @active_tags.pop
    end

    def child_readers
      {
        Sax2pats::Claim => ClaimReader,
        Sax2pats::Citation => CitationReader,
        Sax2pats::Drawing => DrawingReader,
        Sax2pats::Inventor => InventorReader
      }
    end
  end

  class ClaimReader < ElementReader
    def initialize_element
      @element = Claim.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class CitationReader < ElementReader
    def initialize_element
      @element = Citation.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class InventorReader < ElementReader
    def initialize_element
      @element = Inventor.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class DrawingReader < ElementReader
    def initialize_element
      @element = Drawing.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end
end
