module Sax2pats
  class Citation
    include Entity
    attr_accessor :category,
                  :country,
                  :name,
                  :date,
                  :kind,
                  :doc_number,
                  :classification_cpc_text,
                  :classification_national
  end
end
