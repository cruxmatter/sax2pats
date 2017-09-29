module Sax2pats
  class Citation
    include Element
    attr_accessor :category,
                  :country,
                  :name,
                  :date,
                  :kind,
                  :doc_number
  end
end
