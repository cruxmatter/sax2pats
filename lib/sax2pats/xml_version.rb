module Sax2pats
  class XMLVersion
    # 4.2
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

    def custom_version_reader(entity_class)
      case
      when entity_class.eql?(Sax2pats::Claim)
        ClaimVersion.new
      else

      end
    end

    module EntityVersion
      def custom_start(entity, tag_name)
        raise NotImplementedError
      end

      def custom_value(entity, tag_name, value)
        raise NotImplementedError
      end

      def custom_attr(entity, name, value)
        raise NotImplementedError
      end

      def custom_end(entity, tag_name)
        raise NotImplementedError
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
          @claim_text += value.as_s
        when tag_name.eql?('claim-ref')
          @claim_text += value.as_s
        else

        end
      end

      def custom_attr(claim, name, value)
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
  end
end
