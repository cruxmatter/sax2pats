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
      if @xml_version.entity_root([@current_tag]) == Sax2pats::Patent
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
    end

    def end_element(tag_name)
      tag_name = tag_name.to_s
      if @xml_version.entity_root([tag_name]) == Sax2pats::Patent
        @patent_handler.call(@current_reader.entity)
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

    def entity_root(active_tags)
      if active_tags.include?('drawings') && active_tags.last.eql?('figure')
        Sax2pats::Drawing
      else
        ELEMENT_ROOTS[active_tags.last]
      end
    end

    def nested_text?(entity, tag_name)
      NESTED_TEXT_TAGS[entity].include?(tag_name)
    end
  end

  class TextReader
    attr_accessor :xml_version,
                  :root_tag,
                  :text

    def initialize(xml_version)
      @xml_version = xml_version
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

  class EntityReader
    attr_accessor :xml_version,
                  :entity,
                  :entity_class,
                  :active_tags,
                  :current_child_reader,
                  :current_text_reader

    def initialize(xml_version)
      @xml_version = xml_version
      @active_tags = []
      initialize_entity
    end

    def initialize_entity
      raise NotImplementedError
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
      entity = @xml_version.entity_root(@active_tags)
      unless entity.nil?
        @current_child_reader = child_readers[entity].new(@xml_version)
      end
      if @current_child_reader.nil?
        start_entity_attr(tag_name)
      else
        @current_child_reader.start_element(tag_name)
      end
    end

    def start_entity_attr(tag_name)
      if @xml_version.nested_text?(@entity_class, tag_name)
        @current_text_reader = TextReader.new(@xml_version)
        @current_text_reader.root_tag = tag_name
      end
      unless @current_text_reader.nil?
        @current_text_reader.start_element(tag_name)
      end
    end

    def value(value)
      if @current_child_reader.nil?
        if @current_text_reader.nil?
          unless @active_tags.last.nil?
            entity_attr = @entity.sanitize(@active_tags.last).to_sym
            if @entity.respond_to? entity_attr
              @entity.send("#{entity_attr}=".to_sym, value.as_s)
            else
              # puts "undefined attribute #{entity_attr} for #{@entity_class}"
            end
          end
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

    def end_entity_attr(tag_name)
      unless @current_text_reader.nil?
        @current_text_reader.end_element(tag_name)
        if @xml_version.nested_text?(@entity_class, tag_name)
          entity_attr = @entity.sanitize(tag_name).to_sym
          @entity.send("#{entity_attr}=", @current_text_reader.text)
          @current_text_reader = nil
        end
      end
    end

    def end_element(tag_name)
      if @current_child_reader.nil?
        end_entity_attr(tag_name)
      else
        @current_child_reader.end_element(tag_name)
        if child_readers[@xml_version.entity_root(@active_tags)] == @current_child_reader.class
          finish_child(tag_name)
          @current_child_reader = nil
        end
      end
      @active_tags.pop
    end

    def finish_child(tag_name)

    end

    def child_readers
      {}
    end
  end

  class PatentReader < EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Patent
      @entity = Patent.new
    end

    def finish_child(tag_name)
      klass = @current_child_reader.entity.class
      case
      when klass == Sax2pats::Claim
        @entity.claims << @current_child_reader.entity
      when klass == Sax2pats::Citation
        @entity.citations << @current_child_reader.entity
      when klass == Sax2pats::Inventor
        @entity.inventors << @current_child_reader.entity
      when klass == Sax2pats::Drawing
        @entity.drawings << @current_child_reader.entity
      else
      end
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

  class ClaimReader < EntityReader
    def initialize_entity
      @entity_class = Sax2pats::Claim
      @entity = Claim.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class CitationReader < EntityReader
    def initialize_entity
      @entity_class = Sax2pats::Citation
      @entity = Citation.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class InventorReader < EntityReader
    def initialize_entity
      @entity_class = Sax2pats::Inventor
      @entity = Inventor.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end

  class DrawingReader < EntityReader
    def initialize_entity
      @entity_class = Sax2pats::Drawing
      @entity = Drawing.new
    end

    def start_element(tag_name)
      @active_tags.push(tag_name)
    end

    def end_element(tag_name)
      @active_tags.pop
    end
  end
end
