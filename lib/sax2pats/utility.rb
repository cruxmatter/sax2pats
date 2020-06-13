module Sax2pats
  module Utility
    def self.root
      Gem::Specification.find_by_name("sax2pats").gem_dir
    end

    def self.array_wrap(o)
      if is_array?(o)
        o
      else
        [o]
      end
    end

    def self.is_array?(o)
      o.is_a?(Saxerator::Builder::ArrayElement) || o.is_a?(Array)
    end

    def self.is_hash?(o)
      o.is_a?(Saxerator::Builder::HashElement) || o.is_a?(Hash)
    end
  end
end
