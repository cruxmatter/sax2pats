module DocEntity

  def self.included(base)
    base.extend ClassMethods

    base.class_eval do
      attr_accessor :doc, :element
    end
  end

  def as_doc
    self.class.doc_body(element)
  end

  def as_text
    self.class.text_body(element)
  end

  module ClassMethods
    def attr_string(attrs_hash)
      return '' if attrs_hash.to_h.empty?
      " #{attrs_hash.map{ |ak, av| "#{ak}=\"#{av}\"" }.join(' ')}"
    end

    def text_body(text_element)
      if [Saxerator::Builder::StringElement, String].include?(text_element.class)
        return text_element.to_s
      end

      if [Saxerator::Builder::ArrayElement, Array].include?(text_element.class)
        return text_element.map{ |el| self.text_body(el) }.join
      end

      text_element.reject{|k,v| text_element.attributes.include?(k) }
        .map{ |k,v| self.text_body(v) }.join
    end

    def doc_body(text_element)
      attr_string = self.attr_string(text_element.attributes)
      open_tag = if text_element.name
        "<#{text_element.name}#{attr_string}>"
      else
        ''
      end
      close_tag = if text_element.name
        "</#{text_element.name}>"
      else
        ''
      end
      if [Saxerator::Builder::StringElement, String].include?(text_element.class)
        return open_tag +
               text_element.to_s +
               close_tag
      end
      if [Saxerator::Builder::ArrayElement, Array].include?(text_element.class)
        return open_tag +
               text_element.map{ |el| self.doc_body(el) }.join +
               close_tag
      end

      open_tag + text_element.reject{|k,v| text_element.attributes.include?(k) }
        .map{ |k,v| self.doc_body(v) }.join + close_tag
    end
  end
end
