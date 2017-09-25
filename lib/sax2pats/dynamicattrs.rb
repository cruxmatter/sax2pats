module Sax2pats
  module DynamicAttrs
    # https://gist.github.com/davidbella/6918455
    def assign(attr_name, attr_value)
      attr_name = sanitize(attr_name.to_s)
      self.class.send(:define_method, "#{attr_name}=".to_sym) do |value|
        instance_variable_set("@" + attr_name, value)
      end

      self.class.send(:define_method, attr_name.to_sym) do
        instance_variable_get("@" + attr_name)
      end

      self.send("#{attr_name}=".to_sym, attr_value)
    end

    private

    def sanitize(str)
      # TODO thorough sanitization
      str = str.gsub('-','_')
      str = str.gsub('class','patclass')
    end
  end
end
