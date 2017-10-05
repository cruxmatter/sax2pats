module Sax2pats
  class Processor < Ox::Sax

    attr_accessor :current_tag,
                  :current_reader,
                  :patent_handler,
                  :xml_version

    def initialize(patent_handler)
      @patent_handler = patent_handler
      @xml_version = Sax2pats::XMLVersion4_2.new
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
      @current_reader.attr(name, value) unless @current_reader.nil?
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
        @text.concat("<#{tag_name}>")
      end
    end

    def value(value)
      @text.concat(value.as_s)
    end

    def end_element(tag_name)
      unless tag_name.eql? @root_tag
        @text.concat("</#{tag_name}>")
      end
    end
  end

  module EntityReader
    attr_accessor :xml_version,
                  :entity,
                  :entity_class,
                  :active_tags,
                  :current_child_reader,
                  :current_text_reader,
                  :version_reader

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
      unless entity.nil? || child_readers[entity].nil?
        @current_child_reader = child_readers[entity].new(@xml_version)
      end
      if @current_child_reader.nil?
        start_entity_attr(tag_name)
      else
        @current_child_reader.start_element(tag_name)
      end
    end

    def start_entity_attr(tag_name)
      @version_reader.custom_start(@entity, tag_name)
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
        @version_reader.custom_value(@entity, @active_tags.last, value)
        if @current_text_reader.nil?
          unless @active_tags.last.nil?
            entity_attr = @version_reader.attrs_map[@active_tags.last]
            if entity_attr && @entity.respond_to?(entity_attr)
              @entity.send("#{entity_attr}=".to_sym, value.as_s)
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
        @version_reader.custom_attr(@entity, @active_tags.last, name, value)
      else
        @current_child_reader.attr(name, value)
      end
    end

    def end_entity_attr(tag_name)
      @version_reader.custom_end(@entity, tag_name)
      unless @current_text_reader.nil?
        @current_text_reader.end_element(tag_name)
        if @xml_version.nested_text?(@entity_class, tag_name)
          entity_attr = @version_reader.attrs_map[tag_name]
          if entity_attr && @entity.respond_to?(entity_attr)
            @entity.send("#{entity_attr}=", @current_text_reader.text)
          end
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

  class PatentReader
    include EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Patent
      @entity = Patent.new
      @version_reader = @xml_version.version_reader(@entity_class)
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

  class ClaimReader
    include EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Claim
      @entity = Claim.new
      @version_reader = @xml_version.version_reader(@entity_class)
    end
  end

  class CitationReader
    include EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Citation
      @entity = Citation.new
      @version_reader = @xml_version.version_reader(@entity_class)
    end
  end

  class InventorReader
    include EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Inventor
      @entity = Inventor.new
      @version_reader = @xml_version.version_reader(@entity_class)
    end
  end

  class DrawingReader
    include EntityReader

    def initialize_entity
      @entity_class = Sax2pats::Drawing
      @entity = Drawing.new
      @version_reader = @xml_version.version_reader(@entity_class)
    end
  end
end
