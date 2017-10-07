module Sax2pats
  module EntityVersion
    def attrs_map
      {}
    end

    def custom_start(entity, tag_name); end

    def custom_value(entity, tag_name, value); end

    def custom_attr(entity, tag_name, name, value); end

    def custom_end(entity, tag_name); end
  end

  module XMLVersion

    def entity_root(active_tags)
      raise NotImplementedError
    end

    def nested_text?(entity, tag_name)
      raise NotImplementedError
    end

    def version_reader(entity_class)
      case
      when entity_class.eql?(Sax2pats::Claim)
        self.class::ClaimVersion.new
      when entity_class.eql?(Sax2pats::Citation)
        self.class::CitationVersion.new
      when entity_class.eql?(Sax2pats::Patent)
        self.class::PatentVersion.new
      when entity_class.eql?(Sax2pats::Inventor)
        self.class::InventorVersion.new
      when entity_class.eql?(Sax2pats::Drawing)
        self.class::DrawingVersion.new
      else

      end
    end
  end

  class XMLVersion4_5
    include XMLVersion

    ELEMENT_ROOTS = {
      'us-patent-grant' => Sax2pats::Patent,
      'us-citation' => Sax2pats::Citation,
      'claim' => Sax2pats::Claim,
      'inventor' => Sax2pats::Inventor
    }

    NESTED_TEXT_TAGS = {
      Sax2pats::Patent => ['abstract', 'description']
    }

    def entity_root(active_tags)
      if active_tags.include?('drawings') && active_tags.last.eql?('figure')
        Sax2pats::Drawing
      else
        ELEMENT_ROOTS[active_tags.last]
      end
    end

    def nested_text?(entity, tag_name)
      NESTED_TEXT_TAGS.include?(entity) && NESTED_TEXT_TAGS[entity].include?(tag_name)
    end

    class CitationVersion
      include EntityVersion

      def attrs_map
        {
          'category' => :category,
          'name' => :name,
          'date' => :date,
          'doc-number' => :doc_number,
          'country' => :country,
          'kind' => :kind
        }
      end
    end

    class InventorVersion
      include EntityVersion

      def attrs_map
        {
          'city' => 'city',
          'state' => 'state',
          'country' => 'country',
          'first-name' => 'first_name',
          'last-name' => 'last_name'
        }
      end
    end

    class ClaimVersion
      include EntityVersion
      attr_accessor :claim_text

      def custom_start(claim, tag_name)
        case
        when tag_name.eql?('claim-text')
          @claim_text = ""
        else

        end
      end

      def custom_value(claim, tag_name, value)
        case
        when tag_name.eql?('claim-text')
          @claim_text.concat(value.as_s)
        when tag_name.eql?('claim-ref')
          @claim_text.concat(value.as_s)
        else

        end
      end

      def custom_attr(claim, tag_name, name, value)
        case
        when name.eql?(:idref)
          claim.refs << value
        when name.eql?(:id)
          claim.claim_id = value
        else

        end
      end

      def custom_end(claim, tag_name)
        case
        when tag_name.eql?('claim-text')
          claim.text_elements << @claim_text
        else

        end
      end
    end

    class PatentVersion
      include EntityVersion

      def attrs_map
        {
          'invention-title' => :invention_title,
          'date' => :date,
          'number-of-claims' => :number_of_claims,
          'kind' => :kind,
          'abstract' => :abstract,
          'description' => :description
        }
      end
    end

    class DrawingVersion
      include EntityVersion
      attr_accessor :figure, :img

      def attrs_map
        {
          'figure' => :figure,
          'img' => :img
        }
      end

      def custom_attr(drawing, tag_name, name, value)
        case
        when tag_name.eql?('figure')
          @figure = {} if @figure.nil?
          @figure[name] = value
        when tag_name.eql?('img')
          @img = {} if @img.nil?
          @img[name] = value
        else
        end
      end

      def custom_end(drawing, tag_name)
        case
        when tag_name.eql?('figure')
          drawing.figure = @figure
        when tag_name.eql?('img')
          drawing.img = @img
        else

        end
      end
    end
  end
end
