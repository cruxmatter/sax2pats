module Sax2pats
  module Element
    def sanitize(str)
      str = str.gsub('-','_')
      str = str.gsub(/^class$/,'patclass')
    end
  end
end
