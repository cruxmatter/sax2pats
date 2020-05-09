module Sax2pats
  module Utility
    def self.root
      Gem::Specification.find_by_name("sax2pats").gem_dir
    end

    def self.array_wrap(o)
      o.is_a?(Saxerator::Builder::ArrayElement) ? o : [o]
    end
  end
end
