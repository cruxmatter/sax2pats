module Sax2pats
  class Citation
    include Entity
    attr_accessor :category,
                  :document_id,
                  :classification_cpc_text,
                  :classification_national
  end
end
