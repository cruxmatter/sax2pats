module Sax2pats
  module Utility
    def self.array_wrap(o)
      o.is_a?(Saxerator::Builder::ArrayElement) ? o : [o]
    end
  end
end
