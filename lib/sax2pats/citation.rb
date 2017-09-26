module Sax2pats
  class Citation
    include Sax2pats::DynamicAttrs
    attr_accessor :category,
                  :country,
                  :name,
                  :date,
                  :kind,
                  :doc_number
  end
end
